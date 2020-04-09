hc_apache Cookbook
================
Description
===========

This is a wrapper cookbook for community cookbook **apache2**. Since community cookbook was restarting apache service using **:delayed** notification, Apache configuration was failing. To overcome that issue we, overrided those resources in wrapper cookbook to work it properly.

Below is the list of implementations supported by this cookbook.

* arshop_hix
* cp_phix
* sso
* wig_virtualhost.rb

Platforms
=========

* Debian/Ubuntu
* RHEL

Dependencies
============
**apache2**

Usage
=======
As per pur requirement, we need to install below mentioned modules by default by apache installation. These modules are define in **attributes.rb** file
* alias
* filter
* headers
* include
* log_config
* mime 
* negotiation
* rewrite
* authz_core
* authz_host 
* authz_user
* authz_groupfile 
* authn_file
* autoindex 
* deflate 
* dir 
* env 
* logio
* negotiation 
* status
* proxy 
* proxy_http 
* setenvif 
* ssl

Extra modules can also be loaded thorugh attributes.rb file if required.

Below is the list of extra modules enabled for cp_phix implementation through role.

    "hc_apache": {
      "extra_modules": [
        "auth_basic",
        "authn_core",
        "cgid",
        "proxy_balancer",
        "proxy_connect",
        "reqtimeout",
        "slotmem_shm",
        "access_compat"
      ]
    }


References
====
NA

TODOS
====
NA

