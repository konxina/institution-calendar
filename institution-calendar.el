;;; institution-calendar.el --- Show term week numbers in the `calendar' buffer for different institutions -*- lexical-binding: t -*-

;; Copyright (C) 2026  Protesilaos Stavrou

;; Author: Protesilaos Stavrou <info@protesilaos.com>
;; Maintainer: Protesilaos Stavrou <info@protesilaos.com>
;; URL: https://github.com/protesilaos/institution-calendar
;; Version: 0.0.0
;; Package-Requires: ((emacs "28.1"))

;; This file is NOT part of GNU Emacs.

;; This program is free software; you can redistribute it and/or modify
;; it under the terms of the GNU General Public License as published by
;; the Free Software Foundation, either version 3 of the License, or
;; (at your option) any later version.
;;
;; This program is distributed in the hope that it will be useful,
;; but WITHOUT ANY WARRANTY; without even the implied warranty of
;; MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
;; GNU General Public License for more details.
;;
;; You should have received a copy of the GNU General Public License
;; along with this program.  If not, see <https://www.gnu.org/licenses/>.

;;; Commentary:

;; Show term week numbers in the `calendar' buffer for different
;; institutions.  Institutions can be universities or other entities
;; that define named terms with numbered weeks.
;;
;; For the time being this package supports the universities of Oxford
;; and Cambridge, though others can be added upon user request.

;;; Code:

(require 'calendar)
(eval-when-compile (require 'subr-x))

(defgroup institution-calendar nil
  "Show term week numbers in the `calendar' buffer for different institutions.
Institutions can be universities or other entities that define named
terms with numbered weeks."
  :group 'calendar)

(defvar institution-calendar-mode)

(defun institution-calendar--set (symbol value)
  "Set SYMBOL to VALUE and enable `institution-calendar-mode' if needed."
  (set-default symbol value)
  (when institution-calendar-mode
    (institution-calendar-mode 1)))

(defvar institution-calendar-user-entities nil
  "User defined institutions and their calendar data.
This is an alist where each element is a cons cell of the following form:

    (ENTITY . CALENDAR-DATA)

ENTITY is a symbol, while CALENDAR-DATA has the same structure as
`institution-calendar-oxford-university-dates' (i.e. it conforms with
the `institution-calendar-valid-data-p').

Institutions defined here can be passed to `institution-calendar-entity'
via their ENTITY.  They can also have their own command for producing a
calendar that does not interfere with the regular `calendar' command by
evaluating the following:

    (institution-calendar-define-convenience-command ENTITY)

In the above sample, ENTITY should not be quoted as the macro takes care
of that.")

(defcustom institution-calendar-entity 'oxford-university
  "Set the institution whose term dates to display in the `calendar'.
The value is the symbol `oxford-university' or `cambridge-university'.

[Other institutions can be added, based on demand, though users can
define their own institutions via `institution-calendar-user-entities'.]

The value may also be an alist which contains the data of the term names
and corresponding start/end dates.  In this case, the data is of the
same form as `institution-calendar-oxford-university-dates'.

If you set this user option with `setq', you need to enable the
`institution-calendar-mode' again.  The Custom interface does that
internally, if the mode is already enabled.

The command `institution-calendar' works fine with `setq'."
  :type `(choice
          (const :tag "University of Oxford" oxford-university)
          (const :tag "University of Cambridge" cambridge-university)
          ,@(mapcar
             (lambda (element)
               (list 'const (car element)))
             institution-calendar-user-entities)
          (sexp :tag "Data that conforms with `institution-calendar-valid-data-p'"))
  :initialize #'custom-initialize-default
  :set #'institution-calendar--set
  :group 'institution-calendar)

(defcustom institution-calendar-include-extra-week-numbers t
  "Include an extra week before and after the formal term weeks.
For example, if the term has 8 weeks, this adds a week 0 and a week 9 to
them.  These can be useful for planning purposes, as gentle reminders
about the pre and post phases of a term.

If you set this user option with `setq', you need to enable the
`institution-calendar-mode' again.  The Custom interface does that
internally, if the mode is already enabled.

The command `institution-calendar' works fine with `setq'."
  :type 'boolean
  :initialize #'custom-initialize-default
  :set #'institution-calendar--set)

(defcustom institution-calendar-include-intermonth-header nil
  "When non-nil include a header above the term indicators.
The text of the header depends on the value of the user option
`institution-calendar-entity'.  All such headers are defined in
`institution-calendar-intermonth-headers' (users who register their own
institution in `institution-calendar-user-entities' can also update the
`institution-calendar-intermonth-headers' accordingly).

If you set this user option with `setq', you need to enable the
`institution-calendar-mode' again.  The Custom interface does that
internally, if the mode is already enabled.

The command `institution-calendar' works fine with `setq'."
  :type 'boolean
  :initialize #'custom-initialize-default
  :set #'institution-calendar--set)

(defvar institution-calendar-intermonth-headers
  '((cambridge-university . "CA")
    (oxford-university . "OX"))
  "Alist of institution and intermonth header text.
Each element is a cons cell of the form (INSTITUTION . TEXT) where
INSTITUTION is a symbol among those accepted by the user option
`institution-calendar-entity' and TEXT is a two-letter string that
describes the INSTITUTION.")

;; Source: <https://www.ox.ac.uk/about/facts-and-figures/dates-of-term>.
(defvar institution-calendar-oxford-university-dates
  '((2025 (michaelmas (10 12 2025) (12  6 2025))
          (hilary     ( 1 18 2026) ( 3 14 2026))
          (trinity    ( 4 26 2026) ( 6 20 2026)))
    ;; All the rest are PROVISIONAL as of this writing 2025-12-20.
    (2026 (michaelmas (10 11 2026) (12  5 2026))
          (hilary     ( 1 17 2027) ( 3 13 2027))
          (trinity    ( 4 25 2027) ( 6 19 2027)))
    (2027 (michaelmas (10 10 2027) (12  4 2027))
          (hilary     ( 1 16 2028) ( 3 11 2028))
          (trinity    ( 4 23 2028) ( 6 17 2028)))
    (2028 (michaelmas (10  8 2028) (12  2 2028))
          (hilary     ( 1 14 2029) ( 3 10 2029))
          (trinity    ( 4 22 2029) ( 6 16 2029)))
    (2029 (michaelmas (10  7 2029) (12  1 2029))
          (hilary     ( 1 13 2030) ( 3  9 2030))
          (trinity    ( 4 28 2030) ( 6 22 2030)))
    (2030 (michaelmas (10 13 2030) (12  7 2030))
          (hilary     ( 1 19 2031) ( 3 15 2031))
          (trinity    ( 4 27 2031) ( 6 21 2031)))
    (2031 (michaelmas (10 12 2031) (12  6 2031))
          (hilary     ( 1 18 2032) ( 3 13 2032))
          (trinity    ( 4 25 2032) ( 6 19 2032))))
  "Alist of Oxford calendar terms with start and end date.
Each element of the list is of the form (ACADEMIC-YEAR TERMS) where each
of the TERMS is of the form (NAME (START-DATE) (END-DATE)).  The NAME is
`michaelmas', `hilary', or `trinity'.  START-DATE and END-DATE are of
the form (MONTH DAY YEAR).

The ACADEMIC-YEAR is the calendar year at the start of the terms.  For
example, the academic year spanning 2025-2026 has ACADEMIC-YEAR=2025.")

;; Sources:
;;
;; - <https://www.cam.ac.uk/about-the-university/term-dates-and-calendars>
;; - <https://www.admin.cam.ac.uk/univ/so/pdfs/2024/ordinance02.pdf#page=8>
(defvar institution-calendar-cambridge-university-dates
  '((2025 (michaelmas (10  7 2025) (12  5 2025))
          (lent       ( 1 20 2026) ( 3 20 2026))
          (easter     ( 4 28 2026) ( 6 19 2026)))
    (2026 (michaelmas (10  6 2026) (12  4 2026))
          (lent       ( 1 19 2027) ( 3 19 2027))
          (easter     ( 4 27 2027) ( 6 18 2027)))
    ;; All the rest are provisional as of 2026-02-11.
    (2027 (michaelmas (10  5 2027) (12  3 2027))
          (lent       ( 1 18 2028) ( 3 17 2028))
          (easter     ( 4 25 2028) ( 6 16 2028)))
    (2028 (michaelmas (10  3 2028) (12  1 2028))
          (lent       ( 1 16 2029) ( 3 16 2029))
          (easter     ( 4 24 2029) ( 6 15 2029)))
    (2029 (michaelmas (10  2 2029) (11 30 2029))
          (lent       ( 1 15 2030) ( 3 15 2030))
          (easter     ( 4 23 2030) ( 6 14 2030)))
    (2030 (michaelmas (10  8 2030) (12  6 2030))
          (lent       ( 1 21 2031) ( 3 21 2031))
          (easter     ( 4 29 2031) ( 6 20 2031)))
    (2031 (michaelmas (10  7 2031) (12  5 2031))
          (lent       ( 1 20 2032) ( 3 19 2032))
          (easter     ( 4 27 2032) ( 6 18 2032)))
    (2032 (michaelmas (10  5 2032) (12  3 2032))
          (lent       ( 1 18 2033) ( 3 18 2033))
          (easter     ( 4 26 2033) ( 6 17 2033)))
    (2033 (michaelmas (10  4 2033) (12  2 2033))
          (lent       ( 1 17 2034) ( 3 17 2034))
          (easter     ( 4 25 2034) ( 6 16 2034)))
    (2034 (michaelmas (10  3 2034) (12  1 2034))
          (lent       ( 1 16 2035) ( 3 16 2035))
          (easter     ( 4 24 2035) ( 6 15 2035)))
    (2035 (michaelmas (10  2 2035) (11 30 2035))
          (lent       ( 1 15 2036) ( 3 14 2036))
          (easter     ( 4 29 2036) ( 6 20 2036)))
    (2036 (michaelmas (10  7 2036) (12  5 2036))
          (lent       ( 1 20 2037) ( 3 20 2037))
          (easter     ( 4 28 2037) ( 6 19 2037)))
    (2037 (michaelmas (10  6 2037) (12  4 2037))
          (lent       ( 1 19 2038) ( 3 19 2038))
          (easter     ( 4 27 2038) ( 6 18 2038)))
    (2038 (michaelmas (10  5 2038) (12  3 2038))
          (lent       ( 1 18 2039) ( 3 18 2039))
          (easter     ( 4 26 2039) ( 6 17 2039)))
    (2039 (michaelmas (10  4 2039) (12  2 2039))
          (lent       ( 1 17 2040) ( 3 16 2040))
          (easter     ( 4 24 2040) ( 6 15 2040))))
  "Cambridge equivalent of `institution-calendar-oxford-university-dates'.
The terms are `michaelmas', `lent', and `easter'.  See the documentation
of `institution-calendar-oxford-university-dates' for further details.")

(defun institution-calendar--encode-time (date)
  "Encode calendar DATE of (list MONTH DAY YEAR) as a date object."
  (pcase-let ((`(,month ,day ,year) date))
    (encode-time (list 1 1 1 day month year))))

(defface institution-calendar-term-indicator-regular-week
  '((t :inherit calendar-weekday-header))
  "Face to style the indicator for the formal weeks of the term.
For example, if a term has 8 weeks, apply this face to week numbers 1
through 8.")

(defface institution-calendar-term-indicator-extra-week
  '((t :inherit calendar-weekend-header))
  "Face to style the indicator for extra term weeks.
For example, if a term has 8 weeks, apply this face to week 0 and week 9
which, is only relevant if `institution-calendar-include-extra-week-numbers'
is set to a non-nil value.")

(defun institution-calendar--valid-term-p (term)
  "Return non-nil if TERM is valid, per `institution-calendar-valid-data-p'."
  (let ((length-3-fn (lambda (seq) (length= seq 3))))
    (and (listp term)
         (funcall length-3-fn term)
         (symbolp (car term))
         (seq-every-p
          (lambda (element)
            (and (funcall length-3-fn element)
                 (seq-every-p #'integerp element)))
          (cdr term)))))

(defun institution-calendar-valid-data-p (calendar-data)
  "Return non-nil if CALENDAR-DATA has the expected structure.
CALENDAR-DATA is like `institution-calendar-oxford-university-dates'."
  (and (listp calendar-data)
       (seq-every-p
        (lambda (element)
          (and (integerp (car element))
               (seq-every-p #'institution-calendar--valid-term-p (cdr element))))
        calendar-data)))

(defun institution-calendar--get-start-year (month year calendar-data)
  "Return the start year for a given MONTH and YEAR.
The start month is derived from the provided CALENDAR-DATA (which is of
the form defined in `institution-calendar-entity')."
  (let* ((first-year (car calendar-data))
         (academic-year-number (car first-year))
         (terms (cdr first-year))
         (start-months
          (delq nil
                (mapcar (lambda (term)
                          (pcase-let* ((`(,_ ,start-date ,_) term)
                                       (`(,_ ,_ ,start-year) start-date))
                            (when (= start-year academic-year-number)
                              (car start-date))))
                        terms)))
         (academic-year-start-month (when start-months (apply #'min start-months))))
    (if (and academic-year-start-month (>= month academic-year-start-month))
        year
      (- year 1))))

(defun institution-calendar--term-initial (term-name)
  "Return TERM-NAME as its initial letter plus T."
  (thread-first
    (symbol-name term-name)
    (substring 0 1)
    (upcase)))

(defun institution-calendar--user-entity-p (entity)
  "Return non-nil if ENTITY is among `institution-calendar-user-entities'."
  (when-let* ((entities (mapcar #'car institution-calendar-user-entities)))
    (memq entity entities)))

(defun institution-calendar--get-user-entity-data (entity)
  "Return calendar data for user defined ENTITY."
  (when-let* ((data (alist-get entity institution-calendar-user-entities)))
    (if (symbolp data)
        (symbol-value data)
      data)))

(defun institution-calendar--get-data (entity)
  "Return data that corresponds to ENTITY (per `institution-calendar-entity')."
  (pcase entity
    ('cambridge-university institution-calendar-cambridge-university-dates)
    ('oxford-university institution-calendar-oxford-university-dates)
    ((pred institution-calendar--user-entity-p) (institution-calendar--get-user-entity-data entity))
    ((pred institution-calendar-valid-data-p) entity)
    (_ (error "Unsupported value for `institution-calendar-entity'"))))

(defun institution-calendar--get-date-data (current-date terms)
  "Return data for a term containing CURRENT-DATE from a list of TERMS.
CURRENT-DATE is of `institution-calendar--encode-time' form, while TERMS
is a list of term data, per `institution-calendar-entity', for a certain
year.

Return a list of the form (TERM-NAME WEEK-NUMBER IS-EXTRA-WEEK-P), or
nil.  TERM-NAME is the symbol of the given term, as found in TERMS.
WEEK-NUMBER is the number of the week for this term, optionally with
`institution-calendar-include-extra-week-numbers'.  IS-EXTRA-WEEK-P is
either nil or non-nil to ultimately determine whether the extra weeks
should be rendered in the calendar buffer."
  (catch 'found
    (dolist (term-data terms)
      (pcase-let* ((`(,term-name ,start-list ,end-list) term-data))
        (when (and start-list end-list)
          (let* ((start-date (institution-calendar--encode-time start-list))
                 (end-date (institution-calendar--encode-time end-list))
                 (start-day-of-week (nth 6 (decode-time start-date)))
                 (start-of-first-week (time-subtract start-date (days-to-time start-day-of-week)))
                 (end-day-of-week (nth 6 (decode-time end-date)))
                 (end-of-last-week (time-subtract end-date (days-to-time end-day-of-week)))
                 (seconds-in-a-week (float (* 60 60 24 7))))
            (cond
             ((and (not (time-less-p current-date start-of-first-week))
                   (time-less-p current-date start-date))
              (throw 'found (list term-name 1 nil)))
             ((and (not (time-less-p current-date start-date))
                   (time-less-p current-date (time-add end-date (days-to-time 1))))
              (let* ((seconds-since-start (float-time (time-subtract current-date start-of-first-week)))
                     (week-number (1+ (floor (/ seconds-since-start seconds-in-a-week)))))
                (throw 'found (list term-name week-number nil))))
             ((and institution-calendar-include-extra-week-numbers
                   (not (time-less-p current-date (time-subtract start-of-first-week (days-to-time 7))))
                   (time-less-p current-date start-of-first-week))
              (throw 'found (list term-name 0 t)))
             ((and institution-calendar-include-extra-week-numbers
                   (not (time-less-p current-date (time-add end-of-last-week (days-to-time 7))))
                   (time-less-p current-date (time-add end-of-last-week (days-to-time 14))))
              (let* ((seconds-between (float-time (time-subtract end-of-last-week start-of-first-week)))
                     (num-weeks (1+ (floor (/ seconds-between seconds-in-a-week)))))
                (throw 'found (list term-name (1+ num-weeks) t)))))))))))

(defun institution-calendar-week (month day year &optional entity)
  "Use MONTH DAY YEAR to determine current week.
With optional ENTITY use it to retrieve the relevant data, else work
with the data that corresponds to the value of the user option
`institution-calendar-entity'.

Return string of the term's initial letter and week number, if relevant
text properties."
  (let* ((calendar-data (institution-calendar--get-data (or entity institution-calendar-entity)))
         (academic-year (institution-calendar--get-start-year month year calendar-data))
         (terms (alist-get academic-year calendar-data))
         (current-date (institution-calendar--encode-time (list month day year)))
         (term-info (when terms (institution-calendar--get-date-data current-date terms))))
    (if term-info
        (pcase-let* ((`(,term-name ,week-number ,is-extra-week) term-info)
                     (week-string (concat (institution-calendar--term-initial term-name) (number-to-string week-number))))
          (format " %3s " (propertize week-string
                                      'help-echo (format "`%s' term" term-name)
                                      'face (if is-extra-week
                                                'institution-calendar-term-indicator-extra-week
                                              'institution-calendar-term-indicator-regular-week))))
      "   ")))

(defun institution-calendar-intermonth-header (&optional entity)
  "Return string for `calendar-intermonth-header'.
With optional ENTITY, use it instead of `institution-calendar-entity'.

If `institution-calendar-include-intermonth-header' is nil, return a
blank string of appropriate length.  Same if ENTITY does not have a
corresponding header in `institution-calendar-intermonth-headers'."
  (let ((empty "  "))
    (if institution-calendar-include-intermonth-header
        (if-let* ((text (alist-get (or entity institution-calendar-entity) institution-calendar-intermonth-headers)))
            (format "%s" (propertize text 'face 'institution-calendar-term-indicator-extra-week))
          empty)
      empty)))

(defun institution-calendar-setup (&optional entity)
  "Set up the Calendar buffer.
With optional ENTITY, do it for that one only."
  (with-current-buffer (get-buffer "*Calendar*")
    (setq-local calendar-left-margin 10
                calendar-intermonth-spacing 6
                calendar-intermonth-header (institution-calendar-intermonth-header entity)
                calendar-intermonth-text `(institution-calendar-week month day year ',entity))
    (call-interactively #'calendar-redraw)))

;;;###autoload
(defun institution-calendar ()
  "Like `calendar' but with the institution's term week indicators.
Users can rely on this command instead of enabling the
`institution-calendar-mode' if they also need to use the regular
`calendar' command."
  (interactive)
  (call-interactively #'calendar)
  (institution-calendar-setup))

(defmacro institution-calendar-define-convenience-command (entity)
  "Define a variant of `institution-calendar' for the given ENTITY.
ENTITY is among those supported by `institution-calendar-entity'."
  `(defun ,(intern (format "institution-calendar-%s" entity)) ()
     ,(format "Like `institution-calendar' but specifically for the `%s'." entity)
     (interactive)
     (call-interactively #'calendar)
     (institution-calendar-setup ',entity)))

;;;###autoload (autoload 'institution-calendar-cambridge-university "institution-calendar")
(institution-calendar-define-convenience-command cambridge-university)

;;;###autoload (autoload 'institution-calendar-oxford-university "institution-calendar")
(institution-calendar-define-convenience-command oxford-university)

;;;###autoload
(define-minor-mode institution-calendar-mode
  "When non-nil, show Institution Calendar information in the `calendar'.
Modify the `calendar' command to always show indicators about the term
weeks of the institution.

Users who need to keep `calendar' intact while still having access to
the available institution data, can use the command `institution-calendar'."
  :global t
  (if institution-calendar-mode
      (progn
        (setopt calendar-left-margin 10
                calendar-intermonth-spacing 6
                calendar-intermonth-header (institution-calendar-intermonth-header)
                calendar-intermonth-text '(institution-calendar-week month day year))
        (message "Enabled Institution Calendar mode"))
    (setopt calendar-left-margin 5
            calendar-intermonth-spacing 4
            calendar-intermonth-header nil
            calendar-intermonth-text nil)
    (message "Disabled Institution Calendar mode")))

(provide 'institution-calendar)
;;; institution-calendar.el ends here
