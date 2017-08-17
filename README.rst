====================
BiGG Quality Control
====================

This project uses `memote <https://memote.readthedocs.io/>`_ to quality control
and rank accordingly all models present in the `BiGG database`_. Please see the
section on usage_ for more information.

Installation
============

The easiest way to set up the dependencies for this project is to use the
`Makefile <Makefile>`_.

.. code-block:: console

    $ make jupyter

This will install all requirements (defined in ``requirements.txt``) and
configure the Jupyter notebook extensions.

Usage
=====

The main work is done by the scripts that you can find in
``src/data/``.

``download_bigg_models.py``
    Download all the models from the `BiGG database`_ skipping models present in
    ``models/``.
``test_models.py``
    Use memote to perform quality control tests on every model file present in
    ``models/`` in parallel and record test results in ``reports/``.
``rank_models.py``
    Use the test results in ``reports/`` to create a ranking of the models.

You can run everything simply by typing ``make data``.

Contact
=======

For comments and questions get in touch via

* the memote `gitter chatroom <https://gitter.im/opencobra/memote>`_ or
* the memote `mailing list <https://groups.google.com/forum/#!forum/memote>`_.

Copyright
=========

* Copyright (c) 2017, Novo Nordisk Foundation Center for Biosustainability,
  Technical University of Denmark.
* Free software: `Apache Software License 2.0 <LICENSE>`_

.. _`BiGG database`: http://bigg.ucsd.edu/
