"
" Vim script for supporting Django in vim
"
" This script simply add `DJANGO_SETTINGS_MODULE`
"
" Author: Alisue (lambdalisue@hashnote.net)
" Date: 2011/12/08
"
if !has('python')
    echo "Error: Required vim compiled with +python"
    finish
endif

py << EOF
import os
import sys
import vim

if sys.version_info[:2] < (2, 5):
    raise AssertionError('Vim must be compiled with Python 2.5 or higher; you have ' + sys.version)

def find_django_settings_module(root):
    root = os.path.abspath(root)
    project_name = os.path.basename(root)
    root = os.path.dirname(root)
    # Add path to current sys.path
    if root not in sys.path:
        sys.path.insert(0, root)
    # Enable to execute external command or make
    if 'PYTHONPATH' in os.environ:
        if root not in os.environ['PYTHONPATH']:
            os.environ['PYTHONPATH'] = u"%s:%s" % (os.environ['PYTHONPATH'], root)
    else:
        os.environ['PYTHONPATH'] = root
    return "%s.settings" % project_name

if os.path.exists('manage.py') and 'DJANGO_SETTINGS_MODULE' not in os.environ:

    #Virtualenv support
    if 'VIRTUAL_ENV' in os.environ:
        project_base_dir = os.environ['VIRTUAL_ENV']
        sys.path.insert(0, project_base_dir)
        activate_this = os.path.join(project_base_dir, 'bin/activate_this.py')
        execfile(activate_this, dict(__file__=activate_this))
        # Save virtual environment name to VIM variable
        vim.command("let g:pythonworkon = '%s'" % os.path.basename(project_base_dir))

    # try to find settings.py
    settings = None
    for root, dirs, files in os.walk('.'):
        if os.path.exists(os.path.join(root, 'settings.py')):
            settings = find_django_settings_module(root)

    os.environ['DJANGO_SETTINGS_MODULE'] = settings
    # Now try to load django.db
    try:
        import django.db
    except ImportError:
        pass
EOF
