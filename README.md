# External repository metadata

This repository contains metadata for external repositories. It is
available in a signed format from
[pages](https://extrepo-team.pages.debian.net/extrepo-data), which can
be consumed by tools inside Debian; for instance,
[extrepo](https://salsa.debian.org/extrepo-team/extrepo).

# Adding your own external repository

To add metadata for your own external repository, please open a merge
request to add a file called `repos/debian/<your-repo.yaml>` to
the repository. After vetting, the merge request will then be accepted.

To test that your repository metadata follows the proper format, and
that the repository contains everything the metadata describes, run
`tools/check-repos` on your new yaml file, then run `tools/validate-repo`
on your new yaml file. Note that this will require you to install the
packages `libhash-case-perl`, `libyaml-libyaml-perl`, `libwww-perl`,
and `libdistro-info-perl`.

Merge requests are preferably opened by a maintainer or representative
of the repository in question, but this is not a strict requirement.

# Rules for external repositories

In order to be accepted into this repository, the following rules must
be adhered to.

The capitalized words should be interpreted as per
[RFC2119](https://tools.ietf.org/html/rfc2119).

- Packages in external repositories MUST NOT overwrite files from
  packages in the official Debian repositories, *except* if their
  purpose is to provide alternate or more recent versions of software in
  Debian.
- External repositories MUST be signed.
- External repositories MUST declare their license policy as one of
  `main`, `contrib`, or `non-free`. The definition of these policies is
  as for Debian's components:

  - Packages in a component with a `main` policy MUST be
    [DFSG](https://www.debian.org/social_contract#guidelines)-free,
    and SHOULD also provide a deb-src type. These packages MUST NOT be
    built with anything that is not part of the same repository or
    another one with a `main` policy.
  - Packages in a component with a `contrib` policy MUST be
    DFSG-free, and MUST also provide a deb-src type. These packages
    MAY use packages from non-`main` repositories
  - There are no restrictions on packages in a component with a
    `non-free` policy.

- External repositories MUST be maintained; that is, the software in
  these repositories MUST be updated when an update of the software in
  question is made available.
- External repositories SHOULD have a way to report bugs with the
  software in the repository. This bug reporting system does not have to
  be specific to the Debian packages, however.

The maintainers of the extrepo-data repository reserve the right to
update these rules when necessary.

# Reporting problems with external repositories

When there is a problem with an external repository (either the
repository itself, or a package in the repository), please try to contact
the maintainers of the repository in question, first. Information about
the repository may be available through the "contact" and/or "bugs"
items in the repository's metadata.

If that doesn't work, and/or critical issues exist with the repository,
please file an issue against this repository. We will then review it,
and if necessary, remove the repository from the metadata.

# Licenses

The files under `tools/` are available under the terms of the GPL,
version 2 or (at your option) any later version.

The files under `repos` and the file `template.yaml` are available under
the CC0 license (that is, public domain). Do with them what you want.
