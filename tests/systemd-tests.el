;;; systemd-tests.el --- Tests for systemd.el -*- lexical-binding: t -*-

;; Copyright (C) 2016  Mark Oteiza <mvoteiza@udel.edu>

;; Author: Mark Oteiza <mvoteiza@udel.edu>

;; This file is free software; you can redistribute it and/or
;; modify it under the terms of the GNU General Public License
;; as published by the Free Software Foundation; either version 3
;; of the License, or (at your option) any later version.

;; This file is distributed in the hope that it will be useful,
;; but WITHOUT ANY WARRANTY; without even the implied warranty of
;; MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
;; GNU General Public License for more details.

;; You should have received a copy of the GNU General Public License
;; along with this file. If not, see <http://www.gnu.org/licenses/>.

;;; Commentary:

;;; Code:

(require 'ert)
(require 'systemd)

(ert-deftest test-normal-autoloads ()
  "Tests for `systemd-autoload-regexp'.
This should match unit names: alpha-numeric ascii base names,
with exceptions in the set [-_.@\\]. Extensions are a prescribed
list.  Some from systemd.unit(5) are excluded intentionally;
e.g. scope files which are created programmatically."
  (let ((re systemd-autoload-regexp))
    (should (string-match-p re "70-snark-ethernet.link"))
    (should-not (string-match-p re "abusname"))
    (should-not (string-match-p re "busname"))
    ;; Do not match empty unit name
    (should-not (string-match-p re ".service"))
    ;; Non-ASCII exceptions
    (should (string-match-p re "-.mount"))
    (should (string-match-p re "dev-dm\\x2d4.service"))
    (should (string-match-p re "proc-sys-fs-binfmt_misc.automount"))
    (should (string-match-p re "bitlbee@.service"))
    (should (string-match-p re "org.freedesktop.timedate1.busname"))
    ;; Do not match non-ASCII
    (should-not (string-match-p re "割り箸.service"))
    ;; Do not match non-alphanumeric ASCII
    (should-not (string-match-p re "~.service"))))

(ert-deftest test-tempfile-autoloads ()
  "Tests for `systemd-tempfn-autoload-regexp'.
Should match file names generated by \"tempfn_random\" in
src/basic/fileio.c which, to quote its comments, does the
transformation

  /foo/bar/waldo  =>  /foo/bar/.#<extra>waldobaa2a261115984a9

but not plain unit names.  For temp files made from systemctl
edit, <extra> is NULL as of systemd 229."
  (let ((re systemd-tempfn-autoload-regexp))
    (should-not (string-match-p re "/foo/bar/.#waldobaa2a261115984a9"))
    (should (string-match-p re ".#override.conf064d87263873e7f7"))
    (should (string-match-p re ".#FOObar.timer064d87263873e7f7"))
    ;; Do not match just the conf extension or unit names
    (should-not (string-match-p re "override.conf"))
    (should-not (string-match-p re "mmmmm.mount"))))

(ert-deftest test-dropin-autoloads ()
  "Tests for `systemd-dropin-autoload-regexp'.
It should match file names with the \".conf\" extension if and
only if in an appropriately named parent directory."
  (let ((re systemd-dropin-autoload-regexp))
    (should (string-match-p re "/systemd/dog.socket.d/woof.conf"))
    (should-not (string-match-p re "foobar.conf"))
    (should-not (string-match-p re "/etc/modprobe.d/bonding.conf"))
    (should-not (string-match-p re "/etc/systemd/system.conf"))))

(provide 'systemd-tests)

;;; systemd-tests.el ends here

