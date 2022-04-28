# Application Onboarding Checklist

This document contains a list of of tasks and best practices that should be done or incorporated with the application in order to onboard the app to the fleet.

* Yaml best practices
  * The application deployment yaml should specify resource limits.
  * The application resources should be deployed to their own namespace (i.e. not the default namespace).
* Docker image
  * Any Docker images from Docker Hub should be signed and from a trusted, known vendor.
  * "latest" tag should be avoided if possible.
* App versioning
  * Implement app versioning and tag the images accordingly
* Identify any unique app dependencies that are not built in with the cluster.
  * This will likely require additional set up work. The sooner this can be identified the better.
* Identify any app secrets that should be stored as a k8s secret.
* CI/CD
  * Create a CI/CD pipeline for the application.
  * Do not push image to public DockerHub.
  * Incorporate testing into the pipeline.
* Unit Testing
* Linter (program language specific)
* Healthz/Readyz endpoint for monitoring and probes
* Monitoring
  * Logging: Application outputs structured logs (i.e. json) to standard out
  * Metrics: Application is updated to create and emit custom prometheus metrics at the /metrics endpoint (as desired/needed)
    * [Prometheus metric types](https://prometheus.io/docs/concepts/metric_types/)
