=================
memote Meta Study
=================

We collect constraint-based metabolic models from three large repositories (the `BiGG database`_, `University of Minho`_, `M Model Collection`_) and investigate the aggregated results of running the models through memote's test suite.

The goals of this study are:

1. See how publicly accessible models fare on average in memote's tests.
2. Use those insights to calibrate how memote calculates the final test score.

**N.B.: We look at distributions of test metrics because we are not interested
in shaming individual model authors but we are interested in general trends and
the current overall state of models.**

Installation
============

The easiest way to set up the dependencies for this project is to use the
`Makefile <Makefile>`_.

.. code-block:: console

    $ make requirements
    $ make jupyter

This will install all requirements and configure the Jupyter notebook
extensions.

Usage
=====

The main work can be performed via the make command ``make test`` or for more
fine grained control via the command line interface exposed by ``cli.py``.

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
.. _`University of Minho`: http://darwin.di.uminho.pt/models/
.. _`M Model Collection`: https://github.com/opencobra/m_model_collection
