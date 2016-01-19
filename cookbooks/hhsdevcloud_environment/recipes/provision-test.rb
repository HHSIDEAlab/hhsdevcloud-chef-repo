require 'chef/provisioning/aws_driver'
with_driver 'aws::us-east-1'
with_machine_options bootstrap_options: {
#    key_name: "cms-karl",
#    key_path: "/home/karl/workspaces/cms/aws-cms-karl.pem",
    security_group_ids: ['sg-5973d520', 'sg-5f7ed826']
}


machine 'test'
