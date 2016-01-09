cms_environment Cookbook
========================
The "environment cookbook" for the CMS/BlueButton systems. Contains the public roles, recipes, etc. that will be applied to those systems.

Requirements
------------
The dependencies for this cookbook are managed in its `Berksfile`. Be sure to install them:

    $ cd cms_environment
    $ berks install

Attributes
----------
TODO: List your cookbook attributes here.

e.g.
#### cms_environment::default
<table>
  <tr>
    <th>Key</th>
    <th>Type</th>
    <th>Description</th>
    <th>Default</th>
  </tr>
  <tr>
    <td><tt>['cms_environment']['bacon']</tt></td>
    <td>Boolean</td>
    <td>whether to include bacon</td>
    <td><tt>true</tt></td>
  </tr>
</table>

Usage
-----
#### cms_environment::default
TODO: Write usage instructions for each cookbook.

e.g.
Just include `cms_environment` in your node's `run_list`:

```json
{
  "name":"my_node",
  "run_list": [
    "recipe[cms_environment]"
  ]
}
```

License and Authors
-------------------
Authors: Karl M. Davis <karl@justdavis.com>

Licensed under Apache v2.
