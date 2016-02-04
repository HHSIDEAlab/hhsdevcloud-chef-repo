# hhsdevcloud_chef_bootstrap

This cookbook can be used with Chef provisioning to bootstrap the HHS Dev Cloud, by provisioning and configuring a Chef server.

The provisioning can be performed, as follows:

    $ cd hhsdevcloud-chef-repo.git/cookbooks/hhsdevcloud_chef_bootstrap
    $ berks vendor cookbooks
    $ chef-client --local-mode recipes/default.rb

If they do not already exist, this will create the following local resources that you should be aware of:

* `hhsdevcloud_chef_bootstrap/.chef/keys/aws-hhsdevcloud`: The EC2 key pair that the instances trust. This will not be committed to Git (via `.gitignore`), for security reasons but you should absolutely back it up somewhere offline and safe.
* `hhsdevcloud_chef_bootstrap/nodes/`: Chef's "local mode" server stores instances about all of the Chef nodes that were created here. If your provisioning run was against the "production" HHS Dev Cloud, this should be maintained in Git. If not, keep your versions of it on a branch or some such.

## Notes

* <https://www.chef.io/blog/2015/10/08/chef-client-12-5-released/>
    * As of Chef client 12.5, nodes now have `policy_name` and `policy_group` attributes that can be set, rather than editing the values in `client.rb`.
* <https://www.chef.io/blog/2015/11/04/the-road-to-inspec/>
    * InSpec was built for Chef Audit, and is likely "the future" for Test Kitchen tests.
* <https://www.chef.io/blog/2015/11/20/static-analysis-improving-the-quality-and-consistency-of-your-cookbooks/>
    * Foodcritic and Rubocop provide static analysis/linting for cookbooks.
* <https://github.com/chef/chef-dk/issues/193>
    * `Policyfile.rb` is not supported with `--local-mode` yet. It's now been over a year since the last comment on that issue, so.

