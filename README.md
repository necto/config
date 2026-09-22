config
=====

my configuration files ( dotfiles)

Two Guix home profiles share `common.scm`:

    guix home reconfigure ~/config/personal.scm
    guix home reconfigure ~/config/professional.scm

Private layer
-------------

`professional.scm` additionally loads `~/private-config/professional-extras.scm`, a
checkout of a separate, private repository. That is where configuration which should not
be published lives, so that this repository can stay public.

The layer is a Scheme file whose last expression is an alist. `professional.scm` reads
one key from it, `services`: home services appended after every service in `common.scm`,
via its `#:extra-services` argument. Services may extend the same service *type* freely,
but two services must not declare the same target *path*.

It is `load`ed into the same module as `common.scm`, so `local-file`, `simple-service`,
the service types and the package variables are already in scope there.

An absent layer is not an error: `professional.scm` says on stderr that it is
configuring the public parts only, and carries on. `personal.scm` never looks for it.
