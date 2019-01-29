import os

from fabric.api import env, local, execute

try:
    from kubernetes.build_configs import build, build_macondo
except ImportError:
    # In case we are in a container and we want to run fab.
    # Note the container doesn't get the k8s stuff copied to it.
    print('Warning: Failed to import k8s build_configs')

curdir = os.path.dirname(__file__)
print(curdir)

# Don't specify a filename for the key - circle will do the right thing?
# env.key_filename = os.getenv("HOME") + "/.ssh/aerolith.pem"
env.roledefs = {
    'prod_db': ['ubuntu@159.203.220.140']
}


def create_k8s_configs(role):
    execute(_create_k8s_configs, role)


def create_k8s_configs_macondo(role):
    execute(_create_k8s_configs_macondo, role)


def _create_k8s_configs(role):
    build(role)


def _create_k8s_configs_macondo(role):
    build_macondo(role)


def deploy(role):
    execute(_deploy, role)


def deploy_macondo(role):
    execute(_deploy_macondo, role)


def _deploy(role):
    """
    The main deployment function. k8s configs must already be created.

    """
    # To deploy,
    # kubectl --kubeconfig admin.conf apply -f whatever.yaml
    # etc.
    f = '{0}-webolith-migrate-job'.format(role)
    local('kubectl delete --ignore-not-found=true job webolith-migrate')
    local('kubectl apply -f kubernetes/deploy-configs/{0}.yaml'.format(f))
    # Only proceed if the job was successful.
    local('kubectl wait --for=condition=complete --timeout=30s '
          'job/webolith-migrate')

    for f in [
        '{0}-webolith-secrets'.format(role),
        '{0}-webolith-worker-deployment'.format(role),
        'webolith-service',
        '{0}-webolith-ingress'.format(role),
        '{0}-nginx-static-deployment'.format(role),
        'nginx-static-service',
        '{0}-webolith-maintenance'.format(role),
    ]:
        local('kubectl apply -f kubernetes/deploy-configs/{0}.yaml'.format(f))


def _deploy_macondo(role):
    for f in [
        '{0}-macondo-deployment'.format(role),
        'macondo-service',
        '{0}-macondo-secrets'.format(role)
    ]:
        local('kubectl apply -f kubernetes/deploy-configs/{0}.yaml'.format(f))

