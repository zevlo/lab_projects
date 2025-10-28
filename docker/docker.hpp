//
// docker.hpp
// cpp_docker
//

// Header files for system calls
#include <sys/wait.h>   // waitpid
#include <sys/mount.h>  // mount
#include <fcntl.h>      // open
#include <unistd.h>     // execv, sethostname, chroot, fchdir
#include <sched.h>      // clone

// C Standard Library
#include <cstring>

// C++ Standard Library
#include <string>       // std::string

#include <net/if.h>     // if_nametoindex
#include <arpa/inet.h>  // inet_pton
#include "network.h"

#define STACK_SIZE (512 * 512) // Define the size of the child process space

namespace docker {
    // Defined within the `docker` namespace
    typedef int proc_status;
    proc_status proc_err  = -1;
    proc_status proc_exit = 0;
    proc_status proc_wait = 1;
    // Docker container startup configuration
    typedef struct container_config {
        std::string host_name;      // Host name
        std::string root_dir;       // Container root directory
        std::string ip;             // Container IP
        std::string bridge_name;    // Bridge name
        std::string bridge_ip;      // Bridge IP
    } container_config;

    // Save container network devices for deletion
    char *veth1;
    char *veth2;

    class container {
    private:
        // Enhances readability
        typedef int process_pid;

        // Child process stack
        char child_stack[STACK_SIZE];

        // Container configuration
        container_config config;

        // Set the hostname of the container
        void set_hostname() {
            sethostname(this->config.host_name.c_str(), this->config.host_name.length());
        }

        // Set up an independent process namespace
        void set_procsys() {
            // Mount the proc file system
            mount("none", "/proc", "proc", 0, nullptr);
            mount("none", "/sys", "sysfs", 0, nullptr);
        }

        // Set the root directory
        void set_rootdir() {

            // chdir system call, switch to a certain directory
            chdir(this->config.root_dir.c_str());

            // chroot system call, set the root directory, since we have
            // already switched to the current directory earlier
            // we can simply use the current directory as the root directory
            chroot(".");
        }

        void set_network() {

            int ifindex = if_nametoindex("eth0");
            struct in_addr ipv4;
            struct in_addr bcast;
            struct in_addr gateway;

            // IP address transformation function that converts IP addresses between dotted decimal and binary
            inet_pton(AF_INET, this->config.ip.c_str(), &ipv4);
            inet_pton(AF_INET, "255.255.255.0", &bcast);
            inet_pton(AF_INET, this->config.bridge_ip.c_str(), &gateway);

            // Configure the IP address of eth0
            lxc_ipv4_addr_add(ifindex, &ipv4, &bcast, 16);

            // Activate lo
            lxc_netdev_up("lo");

            // Activate eth0
            lxc_netdev_up("eth0");

            // Set the gateway
            lxc_ipv4_gateway_add(ifindex, &gateway);

            // Set the MAC address of eth0
            char mac[18];
            new_hwaddr(mac);
            setup_hw_addr(mac, "eth0");
        }

        void start_bash() {
            // Safely convert C++ std::string to C-style string char *
            // Starting from C++14, this direct assignment is prohibited: `char *str = "test";`
            std::string bash = "/bin/bash";
            char *c_bash = new char[bash.length()+1];   // +1 for '\0'
            strcpy(c_bash, bash.c_str());

            char* const child_args[] = { c_bash, NULL };
            execv(child_args[0], child_args);           // Execute /bin/bash in the child process
            delete []c_bash;
        }
    public:
        container(container_config &config) {
            this->config = config;
        }
        void start() {
            char veth1buf[IFNAMSIZ] = "labex0X";
            char veth2buf[IFNAMSIZ] = "labex0X";
            // Create a pair of network devices, one to be loaded onto the host, and the other to be moved to the container in the child process
            veth1 = lxc_mkifname(veth1buf); // lxc_mkifname API requires at least one "X" to be added to the virtual network device name to support random creation of virtual network devices
            veth2 = lxc_mkifname(veth2buf); // This is to ensure the correct creation of network devices. See the implementation of lxc_mkifname in network.c for details
            lxc_veth_create(veth1, veth2);

            // Set the MAC address of veth1
            setup_private_host_hw_addr(veth1);

            // Add veth1 to the bridge
            lxc_bridge_attach(config.bridge_name.c_str(), veth1);

            // Activate veth1
            lxc_netdev_up(veth1);

            // Some configuration work before container creation
            auto setup = [](void *args) -> int {
                auto _this = reinterpret_cast<container *>(args);
                _this->set_procsys();
                _this->set_network();   // Cooperation for network configuration inside the container
                _this->start_bash();
                return proc_wait;
            };

            // Create the container using clone
            process_pid child_pid = clone(setup, child_stack,
                            CLONE_NEWUTS| // UTS   namespace
                            CLONE_NEWNS|  // Mount namespace
                            CLONE_NEWPID| // PID   namespace
                            CLONE_NEWNET| // Net   namespace
                            SIGCHLD,      // The child process will send a signal to the parent process when it exits
                            this);

            // Move veth2 to the container and rename it as eth0
            lxc_netdev_move_by_name(veth2, child_pid, "eth0");

            waitpid(child_pid, nullptr, 0); // Wait for the child process to exit
        }
        ~container() {
            // Remember to delete the created virtual network devices when exiting
            lxc_netdev_delete_by_name(veth1);
            lxc_netdev_delete_by_name(veth2);
        }
    };
}
