//
// main.cpp
// cpp_docker
//

#include "docker.hpp"
#include <iostream>

int main(int argc, char** argv) {
    std::cout << "...start container" << std::endl;
    docker::container_config config;
    config.host_name = "labex";
    config.root_dir  = "./labex";

    // Configure network parameters
    config.ip        = "192.168.0.100"; // Container IP
    config.bridge_name = "docker0";     // Host bridge
    config.bridge_ip   = "192.168.0.1"; // Host bridge IP

    docker::container container(config);
    container.start();
    std::cout << "stop container..." << std::endl;
    return 0;
}
