import os

from invoke import task

try:
    from kubernetes.build_configs import build, build_word_db_server
except ImportError as e:
    # In case we are in a container and we want to run inv.
    # Note the container doesn't get the k8s stuff copied to it.
    print('Warning: Failed to import k8s build_configs: ', e)

curdir = os.path.dirname(__file__)
print(curdir)


@task
def create_k8s_configs(c, role):
    build(role)


@task
def create_k8s_configs_word_db_server(c, role):
    build_word_db_server(role)


@task
def deploy(c, role):
    """
    The main deployment function. k8s configs must already be created.

    """
    # To deploy,
    # kubectl --kubeconfig admin.conf apply -f whatever.yaml
    # etc.
    f = '{0}-webolith-migrate-job'.format(role)
    c.run('kubectl delete --ignore-not-found=true job webolith-migrate')
    c.run('kubectl apply -f kubernetes/deploy-configs/{0}.yaml'.format(f))
    # Only proceed if the job was successful.
    c.run('kubectl wait --for=condition=complete --timeout=30s '
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
        c.run('kubectl apply -f kubernetes/deploy-configs/{0}.yaml'.format(f))


@task
def deploy_word_db_server(c, role):
    for f in [
        '{0}-word-db-server-deployment'.format(role),
        'word-db-server-service',
        '{0}-word-db-server-secrets'.format(role)
    ]:
        c.run('kubectl apply -f kubernetes/deploy-configs/{0}.yaml'.format(f))
