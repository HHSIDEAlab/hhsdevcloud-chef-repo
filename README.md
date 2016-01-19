The Chef Repository
===================
All Chef installations require a central workspace known as the chef-repo. This is a place where primitive objects--cookbooks, roles, environments, data bags, and chef-repo configuration files--are stored and managed.

This particular repository contains the configuration for the HHS Dev Cloud environment. TODO: describe how it's pushed ot the Chef server, and identify that server

## Deploying

In contrast to most typical Chef repos, this one is designed to be self-bootstrapping: it can be used to provision the Chef Server and the AWS VM that it runs on. Then, it can further be used to provision all of the other VMs and services used in the HHS Dev Cloud.

*(Please note: all instructions here assume an Ubuntu workstation, but can be easily adapted to support Mac or Windows by following the links for additional information.)*

### Deploying: Phase 1: Setup Workstation

Before this repository can be used at all, though, your system must be configured properly to run it. The first step here is to install the ChefDK:

    $ wget https://opscode-omnibus-packages.s3.amazonaws.com/ubuntu/12.04/x86_64/chefdk_0.10.0-1_amd64.deb
    $ sudo dpkg -i chefdk_0.10.0-1_amd64.deb

That's enough for now. Note that there are more install instructions on [Learn Chef: Install the Chef DK](https://docs.chef.io/install_dk.html) to follow, once a Chef server is up & running. For now, though, we'll be using the ChefDK standalone.

In addition, the workstation needs to be configured to properly authenticate to AWS, where the VMs will be created. In order to do this, you'll need two things from the AWS console:

1. An access key (ID and secret), which can be created in IAM, as follows: [Creating, Disabling, and Deleting Access Keys for your AWS Account](http://docs.aws.amazon.com/general/latest/gr/managing-aws-access-keys.html).
2. An EC2 key pair, which can be created in the AWS console, as follows: [Amazon EC2 Key Pairs](http://docs.aws.amazon.com/AWSEC2/latest/UserGuide/ec2-key-pairs.html).

Those aren't specific to Chef; they're needed to use the AWS APIs, which allow programmatic management of AWS resources.

The access key needs to be referenced in a local file along with the AWS region to use. Create `~/.aws/config` and edit as follows:

    [default]
    region=someregion
    aws_access_key_id=somestring
    aws_secret_access_key=some+longer+string

TODO: chef local mode (used to be called Chef Zero, which itself was a replacement for Chef Solo).

### Deploying: Phase 2: Provisioning the Chef Server

TODO

### Deploying: Phase 3: Provisioning Everything Else

Chef client's "local mode" (Chef Zero) can be used to run the `hhsdevcloud_environment::provision` recipe, which will creat and configure all of the other AWS services and instances.

Chef Client's local mode requires all of the cookbooks that will be run and their dependencies to be on the local drive, in a `cookbooks/` directory that is a child of the current working directory. Accordingly, the dependent cookbooks must be pulled in via [Berkshelf](http://berkshelf.com/):

    $ cd hhsdevcloud-chef-repo.git
    $ berks vendor cookbooks --berksfile cookbooks/hhsdevcloud_environment/Berksfile

Please note that this repo's `cookbooks/` directory has a `.gitignore` that ignores all of the vendored cookbooks (everything other than the `hhsdevcloud_environment` cookbook, in fact. This ensures that the cookbooks Berkshelf pulls down with the above command won't accidentally end up committed to this repo.

The `hhsdevcloud_environment::provision` recipe can then be run, as follows:

    $ chef-client --local-mode cookbooks/hhsdevcloud_environment/recipes/provision.rb

While running, this will create a `nodes` and `clients` directory in this repo's root. Chef Client's local mode uses these directories to keep track of what has been provisioned. Before you can run this against a new EC2 account, you'll have to remove those directories, or you'll get weird errors.

