# Nucleobits Backend

## Description

Nucleobits Backend is the core server component of the Nucleobits cloud services platform, focusing on providing efficient and scalable cloud services. Built with a robust C/C++ based architecture, it interfaces with QEMU/KVM for virtualization and leverages gRPC for client-server communication. The nucleobits-backend provides a portable, long term stable C API for managing the virtualization technologies provided by KVM/QEMU.

## Features

- Efficient VM provisioning and management.
- gRPC based API for easy and reliable client-server communication.
- Integration with QEMU/KVM for powerful virtualization capabilities.

## Getting Started

### Prerequisites

- Debian 12 or similar Linux distribution.
- QEMU/KVM for virtualization.
- GCC for compiling C code.
- Docker (optional for containerization).

### Installation

1. Clone the Repository:
   ```bash
   git clone https://github.com/oxdeadcode/Nucleobits-backend.git
   cd Nucleobits-backend
   ```

2. Build the Project:
    ```bash
    make all
    ```

    Or, if using Docker:
    ```bash
    docker build -t nucleobits-backend .
    ```

3. Launch the server
    ```bash
    ./nucleobits-backend
    ```

    Or, if using Docker:
    ```bash
    docker run -d --name nucleobits-backend-container nucleobits-backend
    ```

## Usage

## Contributing

Please see `docs/contributing.md` for more details.

## License

This project is licensed under the MIT License -- see the LICENSE.md file for details.

## Acknowledgements
