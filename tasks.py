import os
from os import path

from invoke import task


webolith_home = os.getenv('WEBOLITH_HOME',
                          path.expanduser('~/coding/webolith'))


@task
def protoc(c):
    js_outpath = path.join(
        webolith_home, 'djAerolith', 'wordwalls', 'static', 'js', 'wordwalls',
        'gen')

    js_out = (f'--js_out=import_style=commonjs,binary:{js_outpath} '
              f'--twirp_js_out=binary:{js_outpath}')
    for proto_path, proto_file in [
        ('rpc/wordsearcher', 'searcher.proto'),
    ]:
        with c.cd('word_db_server'):
            full_path = path.join(proto_path, proto_file)
            py_out_path = path.join(webolith_home, 'djAerolith')
            cmd = (
                f'protoc {js_out} '
                f'--twirp_python_out={py_out_path} '
                f'--python_out={py_out_path} '
                '--twirp_out=paths=source_relative:. '
                '--go_out=paths=source_relative:. '
                f'./{full_path}')
            print(f'running command ... {cmd}')
            c.run(cmd)

