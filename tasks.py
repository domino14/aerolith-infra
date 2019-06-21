import os
from os import path

from invoke import task


webolith_home = os.getenv('WEBOLITH_HOME',
                          path.expanduser('~/coding/webolith'))


@task
def protoc(c):
    js_out = '--js_out=import_style=commonjs:' + path.join(
        webolith_home, 'djAerolith', 'wordwalls', 'static', 'js', 'wordwalls',
        'gen')
    for proto_path, proto_file, output_js in [
        ('rpc/wordsearcher', 'searcher.proto', True),
        ('rpc/anagrammer', 'anagrammer.proto', False),
    ]:
        with c.cd('word_db_server'):
            fsjout = js_out if output_js else ''
            full_path = path.join(proto_path, proto_file)
            py_out_path = path.join(webolith_home, 'djAerolith')
            cmd = (
                f'protoc {fsjout} '
                f'--twirp_python_out={py_out_path} '
                f'--python_out={py_out_path} '
                '--twirp_out=paths=source_relative:. '
                '--go_out=paths=source_relative:. '
                f'./{full_path}')
            print(f'running command ... {cmd}')
            c.run(cmd)

