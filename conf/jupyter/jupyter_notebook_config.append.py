############################
#### Customized Section ####
############################

import io
import os
from notebook.utils import to_api_path
import ntpath

_html_exporter = None

def script_post_save(model, os_path, contents_manager = 'html', **kwargs):
    """convert notebooks to Python script after save with nbconvert

    replaces `ipython notebook --script`
    """
    from nbconvert.exporters.html import HTMLExporter

    if model['type'] != 'notebook':
        return

    global _html_exporter

    if _html_exporter is None:
        _html_exporter = HTMLExporter(parent=contents_manager)

    log = contents_manager.log

    html, resources = _html_exporter.from_filename(os_path)
    base, ext = os.path.splitext(os_path)
    filename = ntpath.basename(base)
    target = '/var/www/html/jupyter/' + filename
    html_fname = target + resources.get('output_extension', '.txt')
    name = resources.get('name', '.txt')
    log.info("Saving html /%s", to_api_path(html_fname, contents_manager.root_dir))

    with io.open(html_fname, 'w', encoding='utf-8') as f:
        f.write(html)

c.FileContentsManager.post_save_hook = script_post_save

c.NotebookApp.password = 'sha1:1148dad8b106:42ca0bf37cb7be292441db82301595a9e7040c06'
c.NotebookApp.password_required = True
c.NotebookApp.port = 8888
c.NotebookApp.token = ''
