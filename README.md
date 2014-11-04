svn_deploy_as_tar
=================

A shell script for deploying specific revisions from an svn repository.

This kind of script is useful if you are forced to use something like AIX Unix and not allowed
to install version control software on production servers (my situation).

It allows an application change to be backed out to a previous version on a host without version control.
Give it a single parm of a version number to use that specific version.

This is meant as an example. It will:

* checkout a specific revision (or the latest if none is specified)
* remove the .svn directories
* create a VERSION text file with the entire svn log output
* create a compressed tar file with the revision number in the name
* deploy it to a hard coded server using scp

To use:

* edit the hard coded variables at the top
* run it
* ssh to the host and untar it when ready to "update production"

The output will show the svn checkout, as well as the following:
```
Checked out revision 297.
Version:            297
Creating:           /home/devops001/fax_r297
Creating:           /home/devops001/fax_r297/VERSION
Unversioning:       /home/devops001/fax_r297
Creating:           /home/devops001/fax_r297.tar
Compressing:        /home/devops001/fax_r297.tar.gz
Removing:           /home/devops001/fax_r297
Finished:           /home/devops001/fax_r297.tar.gz
Copying_To:         FaxHost002
fax_r297.tar.gz                    100%  296KB 296.3KB/s   00:00
```
