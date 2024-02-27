## Onboard AWS EC2 instances to Azure Arc and enable Entra ID authentication using Ansible

This repo includes a way to automatically onboard AWS Linux EC2 instances to Azure Arc using [Ansible](https://www.ansible.com).

## Prerequisites

- Clone this repository

    ```shell
    git clone https://github.com/430am/ArcAWSSSHLoginDemo.git
    ```

- [Install or update Azure CLI to version 2.53.0 or above](https://learn.microsoft.com/cli/azure/install-azure-cli?view=azure-cli-latest). Use the below command to check your currently installed version.

    ```shell
    az --version
    ```

- [Generate a new SSH key pair](https://learn.microsoft.com/azure/virtual-machines/linux/create-ssh-keys-detailed) or use an existing one (Windows 10 and above now comes with a built-in ssh client).

    ```shell
    ssh-keygen -t rsa -b 4096
    ```

    To retrieve the SSH public key after it's been created, depending on your environment, use one of the following methods:
    - On Linux/WSL, use the `cat ~/.ssh/id_rsa.pub` command.
    - On Windows (CMD/PowerShell), use the SSH public key file `id_rsa.pub` which should be located in the `C:\Users\WINUSER\.ssh\` directory.

    SSH public key example output:

    ```shell
    ssh-rsa o1djFhyNe5NXyYk7XVF7wOBAAABgQDO/QPJ6IZHujkGRhiI+6s1ngK8V4OK+iBAa15GRQqd7scWgQ1RUSFAAKUxHn2TJPx/Z/IU60aUVmAq/OV9w0RMrZhQkGQz8CHRXc28S156VMPxjk/gRtrVZXfoXMr86W1nRnyZdVwojy2++sqZeP/2c5GoeRbv06NfmHTHYKyXdn0lPALC6i3OLilFEnm46Wo+azmxDuxwi66RNr9iBi6WdIn/zv7tdeE34VAutmsgPMpynt1+vCgChbdZR7uxwi66RNr9iPdMR7gjx3W7dikQEo1djFhyNe5rrejrgjerggjkXyYk7XVF7wOk0t8KYdXvLlIyYyUCk1cOD2P48ArqgfRxPIwepgW78znYuwiEDss6g0qrFKBcl8vtiJE5Vog/EIZP04XpmaVKmAWNCCGFJereRKNFIl7QfSj3ZLT2ZXkXaoLoaMhA71ko6bKBuSq0G5YaMq3stCfyVVSlHs7nzhYsX6aDU6LwM/BTO1c= user@pc
    ```

- [Create free AWS account](https://aws.amazon.com/premiumsupport/knowledge-center/create-and-activate-aws-account/)

- [Install Terraform >=1.00](https://learn.hashicorp.com/terraform/getting-started/install.html)

- Create Azure service principal (SP)

    To connect the AWS virtual machines to Azure Arc, an Azure service principal assigned with the "Contributor" role is required. To create it, login to your Azure account and run the below command:

    ```shell
    az login
    subscriptionId=$(az account show --query id --output tsv)
    az ad sp create-for-rbac -n "<Unique SP Name>" --role "Contributor" --scopes /subscriptions/$subscriptionId
    ```

    Output should look like this:

    ```json
    {
    "appId": "XXXXXXXXXXXXXXXXX",
    "displayName": "<Unique SP Name>",
    "password": "XXXXXXXXXXXXXXXXX",
    "tenant": "XXXXXXXXXXXXXXXXX"
    }
    ```

    > **Note:** If you create multiple subsequent role assignments on the same principal, your client secret (password) will be destroyed and recreated every time. Make sure to grab the latest password.

    > **Note:** It's highly recommended to scope the service principal to a specific [Azure subscription and resource group](https://learn.microsoft.com/cli/azure/ad/sp?view=azure-cli-latest) as well as considering using a [less privileged service principal](https://learn.microsoft.com/azure/role-based-access-control/best-practices).

- Azure Arc-enabled servers depends on the following Azure resource providers in your subscription in order to use this service. Registration is an asynchronous process and may take up to 10 minutes.

    - Microsoft.HybridCompute
    - Microsoft.GuestConfiguration
    - Microsoft.HybridConnectivity

        ```shell
        az provider register --namespace "Microsoft.HybridCompute"
        az provider register --namespace "Microsoft.GuestConfiguration"
        az provider register --namespace "Microsoft.HybridConnectivity"
        ```

        You can monitor the registration process with the following commands:

        ```shell
        az provider show --namespace "Microsoft.HybridCompute"
        az provider show --namespace "Microsoft.GuestConfiguration"
        az provider show --namespace "Microsoft.HybridConnectivity"
        ```