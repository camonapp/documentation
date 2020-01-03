FROM ddidier/sphinx-doc:latest

RUN pip install --upgrade recommonmark 
RUN pip install sphinx_press_theme
RUN pip install sphinx-copybutton


