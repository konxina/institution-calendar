# Institution calendar (e.g. University of Oxford/Cambridge) for GNU Emacs

SCREENSHOT here: <https://protesilaos.com/codelog/2026-02-11-emacs-institution-calendar/>.

* * *

## Overview

The `institution-calendar` package augments the `M-x calendar` buffer
to include indicators about the applicable term. Each term has week
numbers, which are displayed on the side of the regular calendar data.

The user option `institution-calendar-entity` specifies which
institution's data to use. Currently, the value can be either
`oxford-university` or `cambridge-university`. Contact me and I will
add support for your institution.

Each term shows the week numbers it formally defines. For example, the
University of Oxford has three terms of 8 weeks each. When the user
option `institution-calendar-include-extra-week-numbers` is set to a
non-`nil` value, then an additional two weeks are added: week 0 for
one week before the term starts and an extra number after the term
ends. This is useful for scheduling purposes, such as to arrange
meetings in preparation of the work ahead or to report on what
happened.

The user option `institution-calendar-include-intermonth-header`
writes text above the institution's week indicators. This makes it a
bit easier to tell them apart from the regular calendar data.

## Showing the calendar

Enable the minor mode `institution-calendar-mode` to make all future
calls to `M-x calendar` use the relevant institution data.

If you do not want to affect the `M-x calendar` output, then use the
command `institution-calendar`: it is functionally equivalent to
having the aforementioned minor mode enabled, except it has no
permanent effect on `M-x calendar`---that will keep its original
appearance.

If, for whatever reason, you need to check the calendar of a specific
institution, then do `M-x institution-calendar-cambridge-university`
or `M-x institution-calendar-oxford-university` (more such commands
will be available to match any other institutions that this package
will support).

## Installation and configuration

```elisp
(use-package institution-calendar
  :ensure nil ; not in a package archive
  :init
  (unless (package-installed-p 'institution-calendar)
    (package-vc-install "https://github.com/protesilaos/institution-calendar.git"))
  :commands
  (institution-calendar
   institution-calendar-cambridge-university
   institution-calendar-oxford-university)
  :config
  (setopt institution-calendar-entity 'oxford-university)
  (setopt institution-calendar-include-extra-week-numbers t)
  (setopt institution-calendar-include-intermonth-header nil)

  ;; If you want to permanently change what M-x calendar shows, enable
  ;; this mode.  Otherwise, use the relevant command from the
  ;; :commands listed above.
  (institution-calendar-mode 1))
```

## Sources

+ Git repository: <https://github.com/protesilaos/institution-calendar>
+ Screenshot: <https://protesilaos.com/codelog/2026-02-11-emacs-institution-calendar/>
+ Backronyms: Interestingly Nothing Serving Teachers Implement Term
  Utilities Took Inspiration from Oxford Novices... calendar;
  Institution ... Cambridge Added Lent Entry Notwithstanding Dates
  Already Recorded.
