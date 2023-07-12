# nixploy

This is a deployment guide for Vultr to spin up a basic NixOS VPS. This guide is made specifically for me so it may not work for your purposes.

1. Copy the NixOS minimal x86_64 ISO url and paste it into Vultr's ISO upload dashboard. At the time of writing, this is Nixos 23.05: `https://releases.nixos.org/nixos/23.05/nixos-23.05.1906.8163a64662b/nixos-minimal-23.05.1906.8163a64662b-x86_64-linux.iso`.
2. Deploy a server in Vultr using the custom ISO from the previous step. Select the `Cloud Compute` plan with `AMD High Performance`, deploy in `Los Angeles`, select the uploaded ISO, and select the `1 vCPU and 1 GB RAM` plan, and `disable auto backups`.
3. Open the web console and paste the following commands to perform the rest of the installation via ssh:
    ```sh
    mkdir ~/.ssh
    curl -L https://sam.bossley.us/keys > ~/.ssh/authorized_keys
    ```
4. Log into the machine and set up the environment for installation.
    ```sh
    sudo -i
    nix-shell -p git
    set -o vi
5. Partition the disk. MBR partitioning is required or the VPS may not recognize bootable partitions.
    ```sh
    parted /dev/vda -- mklabel msdos
    parted /dev/vda -- mkpart primary 1MB -2GB
    parted /dev/vda -- mkpart primary linux-swap -2GB 100%
    ```
6. Format each partition.
    ```sh
    mkfs.btrfs -L main /dev/vda1
    mkswap -L swap /dev/vda2
    swapon /dev/vda2
    mount /dev/disk/by-label/main /mnt
    ```
7. Generate a configuration derived from hardware and ensure nothing has changed. Skip this step if it doesn't apply.
    ```sh
    nixos-generate-config --root /mnt
    ```
8. Apply the configuration to the system.
9. Install the operating system.
    ```sh
    nixos-install --no-root-passwd
    mkdir -p /mnt/home/admin/.ssh
    cp /mnt/etc/nixos/keys/keys.pub /mnt/home/admin/.ssh/authorized_keys
    ```
10. In the Vultr dashboard, remove the custom ISO. This will trigger a VPS reboot. Then verify you can access the server as `admin@domain` or `admin@ip` via SSH.
