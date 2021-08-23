# indra_deps_docker

Docker image to build INDRA dependencies including Reach, PySB and Kappa.

## Procedure for updating Docker image on AWS

* Commit changes to Dockerfile in indralab/indra_deps_docker.
* Log into AWS.
* Go to CodeBuild. In list of Build projects, select indra_deps_docker
  and click "Start build".
* If build is successful, proceed to updating build of
  indralab/indra_docker.
