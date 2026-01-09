;;; oxford-calendar.el --- Show Oxford term week numbers in the `calendar' buffer -*- lexical-binding: t -*-

;; Copyright (C) 2026  Free Software Foundation, Inc.

;; Author: Protesilaos Stavrou <info@protesilaos.com>
;; Maintainer: Protesilaos Stavrou <info@protesilaos.com>
;; URL: https://github.com/protesilaos/oxford-calendar
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

;; Show Oxford term week numbers in the `calendar' buffer.  Enable
;; `oxford-calendar-mode' and then call the command `calendar'.  Term
;; weeks are numbered 1 through 8.  The extra weeks 0 and 9 are
;; included by default to make things easier for planning purposes.
;; To opt out, set `oxford-calendar-include-extra-week-numbers' to
;; nil.  To include a heading above the term indicators, set the user
;; option `oxford-calendar-include-intermonth-header' to a non-nil
;; value.

;;; Code:

(defgroup oxford-calendar nil
  "Show Oxford term week numbers in the `calendar' buffer."
  :group 'calendar)

(defvar oxford-calendar-mode)

(defun oxford-calendar--set (symbol value)
  "Set SYMBOL to VALUE and enable `oxford-calendar-mode' if needed."
  (set-default symbol value)
  (when oxford-calendar-mode
    (oxford-calendar-mode 1)))

(defcustom oxford-calendar-include-extra-week-numbers t
  "Include week numbers 0 and 9 to all Oxford calendar terms.
These can be useful for planning purposes, as gentle reminders about the
pre and post phases of a term.

If you change this variable with `setq', you need to enable the
`oxford-calendar-mode' again.  The Custom interface does that
internally, if the mode is already enabled."
  :type 'boolean
  :initialize #'custom-initialize-default
  :set #'oxford-calendar--set)

(defcustom oxford-calendar-include-intermonth-header nil
  "When non-nil include an \"OX\" header above the term indicators."
  :type 'boolean
  :initialize #'custom-initialize-default
  :set #'oxford-calendar--set)

;; NOTE 2025-01-09: Perhaps there is some formula to always get the
;; dates, but I am not aware of it.  As such, these dates need to be
;; updated at the start of each school year.
;;
;; Source: <https://www.ox.ac.uk/about/facts-and-figures/dates-of-term>.
;;
;; TODO 2025-12-20: Maybe we can have a function that fetches this
;; data?  Right now I did it manually, but this is prone to errors.
;; Aligning the dates helps, but still...
(defvar oxford-calendar-dates
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

(defun oxford-calendar--encode-time (date)
  "Encode calendar DATE of (list MONTH DAY YEAR) as a date object."
  (pcase-let ((`(,month ,day ,year) date))
    (encode-time (list 1 1 1 day month year))))

(defun oxford-calendar--get-week-number (date)
  "Return week number of DATE (list MONTH DAY YEAR) starting on a Sunday."
  (let* ((date-object (oxford-calendar--encode-time date))
         (string (format-time-string "%-U" date-object)))
    (string-to-number string)))

(defun oxford-calendar--get-term-week (term-start-week term-end-week calendar-week prefix)
  "Return the week number of the Oxford term or nil.
Determine the number based on TERM-START-WEEK, TERM-END-WEEK, and
CALENDAR-WEEK.  Each term consists of 8 weeks.

If `oxford-calendar-include-extra-week-numbers' is non-nil return a week
0 for the week before TERM-START-WEEK and a week 9 for the week after
TERM-END-WEEK.

Prepend PREFIX string to the number."
  (when (and term-start-week term-end-week calendar-week)
    (when-let* ((number (cond
                         ((and (>= calendar-week term-start-week)
                               (<= calendar-week term-end-week))
                          (+ 1 (- calendar-week term-start-week)))
                         ((and oxford-calendar-include-extra-week-numbers
                               (= calendar-week (- term-start-week 1)))
                          0)
                         ((and oxford-calendar-include-extra-week-numbers
                               (= calendar-week (+ term-end-week 1)))
                          9))))
      (concat prefix (number-to-string number)))))

(defun oxford-calendar--get-term-weeks (term year terms)
  "Return Oxford TERM start and end week numbers as a list from TERMS.
Check YEAR to determine if the date is out of bonds of the term dates."
  (pcase-let* ((`(,beg-date ,end-date) (alist-get term terms))
               (`(,_ ,_ ,term-year) beg-date)
               (beg-week (oxford-calendar--get-week-number beg-date))
               (end-week (oxford-calendar--get-week-number end-date)))
    (when (= term-year year)
      (list beg-week end-week))))

(defface oxford-calendar-term-indicator-regular-week '((t :inherit font-lock-string-face))
  "Face to style the Oxford term indicator for weeks 1 through 8.")

(defface oxford-calendar-term-indicator-extra-week '((t :inherit shadow))
  "Face to style the Oxford term indicator for weeks 0 and 9.
Also see `oxford-calendar-include-extra-week-numbers'.")

(defun oxford-calendar--get-start-year (month year)
  "Return the start of the academic year for a given MONTH and YEAR."
  (if (>= month 10)
      year
    (- year 1)))

(defun oxford-calendar-week (month day year)
  "Use MONTH DAY YEAR to determine current week.
Derive the Oxford term week based on the `oxford-calendar-dates'."
  (let* ((academic-year (oxford-calendar--get-start-year month year))
         (terms (alist-get academic-year oxford-calendar-dates)))
    (pcase-let* ((`(,m-w-beg ,m-w-end) (oxford-calendar--get-term-weeks 'michaelmas year terms))
                 (`(,h-w-beg ,h-w-end) (oxford-calendar--get-term-weeks 'hilary year terms))
                 (`(,t-w-beg ,t-w-end) (oxford-calendar--get-term-weeks 'trinity year terms))
                 (calendar-week (oxford-calendar--get-week-number (list month day year)))
                 (oxford-week (or (oxford-calendar--get-term-week m-w-beg m-w-end calendar-week "MT")
                                  (oxford-calendar--get-term-week h-w-beg h-w-end calendar-week "HT")
                                  (oxford-calendar--get-term-week t-w-beg t-w-end calendar-week "TT")
                                  "")))
      (format " %3s " (propertize oxford-week 'face (if (or (string-suffix-p "0" oxford-week)
                                                            (string-suffix-p "9" oxford-week))
                                                        'oxford-calendar-term-indicator-extra-week
                                                      'oxford-calendar-term-indicator-regular-week))))))

(defun oxford-calendar-intermonth-header ()
  "Return string for `calendar-intermonth-header'."
  (if oxford-calendar-include-intermonth-header
      (format "%s" (propertize "OX" 'face 'oxford-calendar-term-indicator-extra-week))
    "  "))

;;;###autoload
(define-minor-mode oxford-calendar-mode
  "When non-nil, show Oxford calendar information in the `calendar'."
  :global t
  :lighter " OX"
  (if oxford-calendar-mode
      (progn
        (setopt calendar-left-margin 10
                calendar-intermonth-spacing 6
                calendar-intermonth-header (oxford-calendar-intermonth-header)
                calendar-intermonth-text '(oxford-calendar-week month day year))
        (message "Enabled Oxford calendar mode"))
    (setopt calendar-left-margin 5
            calendar-intermonth-spacing 4
            calendar-intermonth-header nil
            calendar-intermonth-text nil)
    (message "Disabled Oxford calendar mode")))

(provide 'oxford-calendar)
;;; oxford-calendar.el ends here
