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
`institution-calendar-intermonth-headers'.

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

(defcustom institution-calendar-entity 'oxford-university
  "Set the institution whose term dates to display in the `calendar'.
The value is the symbol `oxford-university' or `cambridge-university'.
Other institutions can be added, based on demand.

If you set this user option with `setq', you need to enable the
`institution-calendar-mode' again.  The Custom interface does that
internally, if the mode is already enabled.

The command `institution-calendar' works fine with `setq'."
  :type '(radio
          (const :tag "University of Oxford" oxford-university)
          (const :tag "University of Cambridge" cambridge-university))
  :initialize #'custom-initialize-default
  :set #'institution-calendar--set
  :group 'institution-calendar)

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
  "University of Cambridge equivalent of `institution-calendar-oxford-university-dates'.
The terms are `michaelmas', `lent', and `easter'.  See the documentation
of `institution-calendar-oxford-university-dates' for further details.")

(defun institution-calendar--encode-time (date)
  "Encode calendar DATE of (list MONTH DAY YEAR) as a date object."
  (pcase-let ((`(,month ,day ,year) date))
    (encode-time (list 1 1 1 day month year))))

(defun institution-calendar--get-week-number (date)
  "Return week number of DATE (list MONTH DAY YEAR) starting on a Sunday."
  (let* ((date-object (institution-calendar--encode-time date))
         (string (format-time-string "%-U" date-object)))
    (string-to-number string)))

(defun institution-calendar--term-length (term-start-week term-end-week)
  "Calculate the length of a term in weeks.
TERM-START-WEEK and TERM-END-WEEK are week numbers."
  (when (and term-start-week term-end-week)
    (+ (- term-end-week term-start-week) 1)))

(defun institution-calendar--get-term-week (term-start-week term-end-week calendar-week prefix)
  "Return the week number of the term and whether it's an extra week, else nil.
Determine the week number based on TERM-START-WEEK, TERM-END-WEEK, and
CALENDAR-WEEK.  If there is a week number, return a cons cell of the
form (WEEK-NUMBER . IS-EXTRA-WEEK-P).  WEEK-NUMBER is a string with the
PREFIX and number of the week, while IS-EXTRA-WEEK-P is either nil or
non-nil (per `institution-calendar-include-extra-week-numbers').

If `institution-calendar-include-extra-week-numbers' is non-nil return a
week 0 for the week before TERM-START-WEEK and a week number after the
TERM-END-WEEK."
  (when (and term-start-week term-end-week calendar-week)
    (let* ((term-length (institution-calendar--term-length term-start-week term-end-week))
           (week-after-term (when term-length (+ term-length 1)))
           (week-number (cond
                         ((and (>= calendar-week term-start-week)
                               (<= calendar-week term-end-week))
                          (+ (- calendar-week term-start-week) 1))
                         ((and institution-calendar-include-extra-week-numbers
                               (= calendar-week (- term-start-week 1)))
                          0)
                         ((and institution-calendar-include-extra-week-numbers
                               week-after-term
                               (= calendar-week (+ term-end-week 1)))
                          week-after-term))))
      (when week-number
        (let ((is-extra-week (or (= week-number 0)
                                 (and week-after-term
                                      (= week-number week-after-term)))))
          (cons (concat prefix (number-to-string week-number)) is-extra-week))))))

(defun institution-calendar--get-term-weeks (term year terms)
  "Return TERM start and end week numbers as a list, given TERMS.
Check YEAR to determine if the date is out of bonds of the term dates
and return nil if that is the case."
  (pcase-let* ((`(,beg-date ,end-date) (alist-get term terms))
               (`(,_ ,_ ,term-year) beg-date)
               (beg-week (institution-calendar--get-week-number beg-date))
               (end-week (institution-calendar--get-week-number end-date)))
    (when (= term-year year)
      (list beg-week end-week))))

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

(defun institution-calendar--get-start-year (month year)
  "Return the start of the academic year for a given MONTH and YEAR."
  (if (>= month 10)
      year
    (- year 1)))

(defun institution-calendar--term-initial (term-name)
  "Return TERM-NAME as its initial letter plus T."
  (thread-first
    (symbol-name term-name)
    (substring 0 1)
    (upcase)))

(defun institution-calendar--get-data (entity)
  "Return data that corresponds to ENTITY (per `institution-calendar-entity')."
  (pcase entity
    ('cambridge-university institution-calendar-cambridge-university-dates)
    ('oxford-university institution-calendar-oxford-university-dates)
    (_ (error "Unsupported value for `institution-calendar-entity'"))))

(defun institution-calendar--get-term-names (calendar-data)
  "Get term names from DATA.
CALENDAR-DATA is what is implied by `institution-calendar-entity',
such as `institution-calendar-oxford-university-dates'."
  (mapcar #'car (cdr (car calendar-data))))

(defun institution-calendar-week (month day year &optional entity)
  "Use MONTH DAY YEAR to determine current week.
With optional ENTITY use it to retrieve the relevant data, else work
with the data that corresponds to the value of the user option
`institution-calendar-entity'.

Return string of the term's initial letter and week number, if relevant
text properties."
  (let* ((calendar-data (institution-calendar--get-data (or entity institution-calendar-entity)))
         (academic-year (institution-calendar--get-start-year month year))
         (terms (alist-get academic-year calendar-data))
         (term-names (institution-calendar--get-term-names calendar-data))
         (calendar-week (institution-calendar--get-week-number (list month day year)))
         (found-week-info nil)
         (found-term-name nil))
    (catch :exit
      (dolist (term-name term-names)
        (when-let* ((term-weeks-pair (institution-calendar--get-term-weeks term-name year terms))
                    (beg-week (car term-weeks-pair))
                    (end-week (cadr term-weeks-pair))
                    (term-initial (institution-calendar--term-initial term-name))
                    (week-info (institution-calendar--get-term-week beg-week end-week calendar-week term-initial)))
          (setq found-week-info week-info)
          (setq found-term-name term-name)
          (throw :exit t))))
    (let* ((week-string (car found-week-info))
           (is-extra-week (cdr found-week-info)))
      (format " %3s " (propertize (or week-string "")
                                  'help-echo (format "`%s' term" found-term-name)
                                  'face (if is-extra-week
                                             'institution-calendar-term-indicator-extra-week
                                           'institution-calendar-term-indicator-regular-week))))))

(defun institution-calendar-intermonth-header (&optional entity)
  "Return string for `calendar-intermonth-header'.
With optional ENTITY, use it instead of `institution-calendar-entity'."
  (if institution-calendar-include-intermonth-header
      (let ((text (alist-get (or entity institution-calendar-entity) institution-calendar-intermonth-headers)))
        (format "%s" (propertize text 'face 'institution-calendar-term-indicator-extra-week)))
    "  "))

;;;###autoload
(defun institution-calendar ()
  "Like `calendar' but with the institution's term week indicators.
Users can rely on this command instead of enabling the
`institution-calendar-mode' if they also need to use the regular
`calendar' command."
  (interactive)
  (call-interactively #'calendar)
  (with-current-buffer (get-buffer "*Calendar*")
    (setq-local calendar-left-margin 10)
    (setq-local calendar-intermonth-spacing 6)
    (setq-local calendar-intermonth-header (institution-calendar-intermonth-header))
    (setq-local calendar-intermonth-text '(institution-calendar-week month day year))
    (call-interactively #'calendar-redraw)))

;; TODO 2026-02-11: We can have a function that returns all supported
;; entities. Then here we add the relevant error check.
(defmacro institution-calendar-define-convenience-command (entity)
  "Define a variant of `institution-calendar' for the given ENTITY.
ENTITY is among those supported by `institution-calendar-entity'."
  `(defun ,(intern (format "institution-calendar-%s" entity)) ()
     "Like `institution-calendar' but specifically for the University of Oxford."
     (interactive)
     (call-interactively #'calendar)
     (with-current-buffer (get-buffer "*Calendar*")
       (setq-local calendar-left-margin 10)
       (setq-local calendar-intermonth-spacing 6)
       (setq-local calendar-intermonth-header (institution-calendar-intermonth-header ',entity))
       (setq-local calendar-intermonth-text '(institution-calendar-week month day year ',entity))
       (call-interactively #'calendar-redraw))))

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
  :lighter " IC"
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
