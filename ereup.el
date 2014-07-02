#!/usr/bin/emacs --script

;; ----------------------------------------------------------------------------

;;; ereup.el --- Automatization of support YMZ-530 ECU SW repository.

;; Copyright (C) 2014 Artem Petrov <pa2311@gmail.com>

;; Author: Artem Petrov <pa2311@gmail.com>
;; Created: 02 July 2014
;; Version: 0.9.0

;; This file is not part of GNU Emacs.

;; This program is free software; you can redistribute it and/or modify
;; it under the terms of the GNU General Public License as published by
;; the Free Software Foundation, either version 3 of the License, or
;; (at your option) any later version.

;; This program is distributed in the hope that it will be useful,
;; but WITHOUT ANY WARRANTY; without even the implied warranty of
;; MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE. See the
;; GNU General Public License for more details.

;; You should have received a copy of the GNU General Public License
;; along with this program. If not, see <http://www.gnu.org/licenses/>.

;; ----------------------------------------------------------------------------

;; hex file naming convension
;; example: P_986.2.0.0_YMZ-536_S3.14_15.05.2014.hex
;; where P_986      - software platform
;;       2.0.0      - software version
;;       YMZ-536    - engine model
;;       S3.14      - calibration version (S  - serial production or D - development branch,
;;                                         3  - engine generation,
;;                                         14 - calibration data version)
;;       15.05.2014 - release data

;; ----------------------------------------------------------------------------

;;;; identification

(defvar ereup-version "\tereup v0.9.0")
(defvar ereup-system-info (concat "\n\tEmacs v" emacs-version " on "
                                  (prin1-to-string system-type) " " system-name))
(defvar ereup-description "\nAutomatization of support YMZ-530 ECU SW repository.")
(defvar ereup-copyright "\nCopyright (C) 2014 Artem Petrov <pa2311@gmail.com>")
(defvar ereup-src-hosting "\nSource code hosting: https://github.com/pa23/ereup")
(defvar ereup-authors-blog "Author's blog (RU): http://pa2311.blogspot.com")
(defvar ereup-license "\nThis program comes with ABSOLUTELY NO WARRANTY. This is free software,\nand you are welcome to redistribute it under the terms of the GNU General\nPublic License version 3. See http://www.gnu.org/licenses/.")

;;;; settings container

(defvar ereup-conf (make-hash-table :test 'equal) "Hashtable with ereup configuration.")

;;;; environment settings

(when (equal system-type "windows-nt")
  (setq file-name-coding-system 'windows-1251) )

;;;; function definitions

;; auxiliary functions

(defun ereup-init ()
  "Initialize program configuration."
  (puthash "local-repo-dir" "YMZ-530_ECU_SW_REPO" ereup-conf) ; relative
  (puthash "remote-repo-dir" "r:/Applications/Репозиторий калибровок ЭБУ/YMZ-530_ECU_SW_REPO" ereup-conf) ; absolute
  (puthash "hex-files-dir" "hex" ereup-conf) ; only dir name
  (puthash "mpk-files-dir" "mpk" ereup-conf) ; only dir name
  (puthash "doc-files-dir" "doc" ereup-conf) ; only dir name
  (puthash "engine-descr-file" "YMZ-530_hex.html" ereup-conf)
  (puthash "trimhex-dir" "THex" ereup-conf) ; save new hexes from INCA here
  (puthash "trimhex-exec" "trimmhex.bat" ereup-conf)
  (puthash "arch-exec" "7z" ereup-conf)
  (puthash "arch-params" "a" ereup-conf)
  (puthash "k2rei-swver-addr" "1E5B8A" ereup-conf)
  (puthash "k2rei-swver-length" "64" ereup-conf)
  (puthash "file-ext-del" ["hex" "7z" "zip" "ini" "txt"] ereup-conf)
  )

(defun ereup-calc-md5 (file-name)
  (let ((md5-summ))
    (setq md5-summ (md5 (find-file-literally file-name)))
    (kill-buffer (current-buffer))
    md5-summ )
  )

;; menu functions

(defun ereup-show-menu ()
  "Show program's menu."
  (message "\nMenu:")
  (message "  1. Trim available hex files")
;  (message "  2. Update hex identification")
  (message "  3. Archive trimmed hex files")
  (message "  4. Update engine description file")
  (message "  5. Add new hex and mpk files to repository")
  (message "  6. Clean trimmhex directory")
  (message "  7. Publish repository")
  (message "  8. Archive repository")
  (message "  9. About program")
  (message "  0. Exit after execution of all tasts\n")
  )

(defun ereup-trim-hexes ()
  "Trim available hex files."
  (message "\n ereup -> Trimming available hex files...")
  (let ((trimhex-dir (gethash "trimhex-dir" ereup-conf))
        (trimhex-exec (gethash "trimhex-exec" ereup-conf))
        (files)
        (program-dir (file-name-directory load-file-name)))
    (if (and (file-exists-p trimhex-dir)
             (file-exists-p (concat trimhex-dir "/" trimhex-exec)))
        (progn
          (setq files (directory-files trimhex-dir nil "[\/\\a-zA-Z0-9\:\_\.\-]+\.hex$"))
          (cd trimhex-dir)
          (mapc (lambda (file-name)
                  (when (< (nth 7 (file-attributes file-name)) 5000000)
                    (shell-command-to-string (concat trimhex-exec " " file-name)) ) )
                files )
          (cd program-dir) )
      (message " ereup ERROR => Trimhex directory or executable not found!") ) )
  (message " ereup -> Done.")
  )

(defun ereup-upd-hex-id ()
  "Update hex identification."
  ;;
  )

(defun ereup-arch-trimmed-hexes ()
  "Archive trimmed hex files."
  (message "\n ereup -> Archiving trimmed hex files...")
  (let ((trimhex-dir (gethash "trimhex-dir" ereup-conf))
        (arch-exec (gethash "arch-exec" ereup-conf))
        (arch-params (gethash "arch-params" ereup-conf))
        (files))
    (if (file-exists-p trimhex-dir)
        (progn
          (setq files (directory-files trimhex-dir t "[\/\\a-zA-Z0-9\:\_\.\-]+\.hex$"))
          (mapc (lambda (file-name)
                  (when (> (nth 7 (file-attributes file-name)) 5000000)
                    (shell-command-to-string (concat arch-exec " " arch-params " "
                                                     file-name ".7z " file-name)) ) )
                files ) )
      (message " ereup ERROR => Trimhex directory not found!") ) )
  (message " ereup -> Done.")
  )

(defun ereup-upd-eng-descr-file ()
  "Update engine description file."
  (message "\n ereup -> Updating engine description file...")
  (let ((trimhex-dir (gethash "trimhex-dir" ereup-conf))
        (engine-descr-file (concat (gethash "local-repo-dir" ereup-conf) "/"
                                   (gethash "doc-files-dir" ereup-conf) "/"
                                   (gethash "engine-descr-file" ereup-conf)))
        (program-dir (file-name-directory load-file-name))
        (files)
        (file-name-parts)
        (current-line nil))
    (if (and (file-exists-p trimhex-dir) (file-exists-p engine-descr-file))
        (progn
          (setq files (directory-files trimhex-dir t "[\/\\a-zA-Z0-9\:\_\.\-]+\.hex$"))
          (find-file engine-descr-file)
          (mapc (lambda (file-name)
                  (setq file-name-parts (split-string file-name "_" t))
                  (when (equal (length file-name-parts) 5)
                    (goto-char (point-min))
                    (setq current-line nil)
                    (setq current-line (search-forward (concat (nth 2 file-name-parts) "_")))
                    (when current-line
                      (beginning-of-line)
                      (delete-region (point) (line-end-position))
                      (insert (concat "            <td>" (file-name-nondirectory file-name)
                                      "<br>(" (ereup-calc-md5 file-name) ")</td>")) ) ) )
                  files )
                (save-buffer (current-buffer))
                (kill-buffer (current-buffer))
                (cd program-dir) )
          (message " ereup ERROR => Trimhex directory not found!") ) )
  (message " ereup -> Done.")
  )

(defun ereup-add-new-to-repo ()
  "Add new hex and mpk files to repository."
  (message "\n ereup -> Adding new hex and mpk files to repository...")
  (let ((trimhex-dir (gethash "trimhex-dir" ereup-conf))
        (local-repo-hex-dir (concat (gethash "local-repo-dir" ereup-conf) "/"
                                    (gethash "hex-files-dir" ereup-conf)))
        (local-repo-mpk-dir (concat (gethash "local-repo-dir" ereup-conf) "/"
                                    (gethash "mpk-files-dir" ereup-conf)))
        (new-files)
        (old-files)
        (new-parts)
        (old-parts)
        (eng-model-in-new)
        (eng-model-in-old))
    (if (and (file-exists-p trimhex-dir)
             (file-exists-p local-repo-hex-dir)
             (file-exists-p local-repo-mpk-dir))
        (progn
          (setq new-files (directory-files trimhex-dir t "[\/\\a-zA-Z0-9\:\_\.\-]+\.hex$"))
          (setq old-files (directory-files local-repo-hex-dir t "[\/\\a-zA-Z0-9\:\_\.\-]+\.hex$"))
          (mapc (lambda (new-file)
                  (setq new-parts (split-string (file-name-nondirectory new-file) "_" t))
                  (when (equal (length new-parts) 5)
                    (setq eng-model-in-new (concat (nth 2 new-parts) "_"))
                    (mapc (lambda (old-file)
                            (setq old-parts (split-string (file-name-nondirectory old-file) "_" t))
                            (when (equal (length old-parts) 5)
                              (setq eng-model-in-old (concat (nth 2 old-parts) "_"))
                              (when (equal eng-model-in-new eng-model-in-old)
                                (delete-file old-file) ) ) )
                          old-files )
                    (copy-file new-file local-repo-hex-dir t) ) )
                new-files )
          (setq new-files (directory-files trimhex-dir t "[\/\\a-zA-Z0-9\:\_\.\-]+\.zip$"))
          (setq old-files (directory-files local-repo-mpk-dir t "[\/\\a-zA-Z0-9\:\_\.\-]+\.zip$"))
          (mapc (lambda (new-file)
                  (setq new-parts (split-string (file-name-nondirectory new-file) "_" t))
                  (when (equal (length new-parts) 5)
                    (setq eng-model-in-new (concat (nth 2 new-parts) "_"))
                    (mapc (lambda (old-file)
                            (setq old-parts (split-string (file-name-nondirectory old-file) "_" t))
                            (when (equal (length old-parts) 5)
                              (setq eng-model-in-old (concat (nth 2 old-parts) "_"))
                              (when (equal eng-model-in-new eng-model-in-old)
                                (delete-file old-file) ) ) )
                          old-files )
                    (copy-file new-file local-repo-mpk-dir t) ) )
                new-files ) )
      (message " ereup ERROR => Trimhex or local repo directory not found!") ) )
  (message " ereup -> Done.")
  )

(defun ereup-clean-dir ()
  "Clean trimmhex directory."
  (message "\n ereup -> Cleaning trimhex directory...")
  (let ((trimhex-dir (gethash "trimhex-dir" ereup-conf))
        (file-exts (gethash "file-ext-del" ereup-conf))
        (files))
    (if (file-exists-p trimhex-dir)
        (mapc (lambda (file-ext)
                (setq files (directory-files trimhex-dir t
                                             (concat "[\/\\a-zA-Z0-9\:\_\.\-]+\." file-ext "$")))
                (mapc (lambda (curr-file-name)
                        (delete-file curr-file-name) )
                      files ) )
              file-exts )
      (message " ereup ERROR => Trimhex directory not found!") ) )
  (message " ereup -> Done.")
  )

(defun ereup-publish-repo ()
  "Publish repository."
  (message "\n ereup -> Publishing repository...")
  (let ((local-repo-dir (gethash "local-repo-dir" ereup-conf))
        (remote-repo-dir (gethash "remote-repo-dir" ereup-conf))
        (hex-files-dir (gethash "hex-files-dir" ereup-conf))
        (mpk-files-dir (gethash "mpk-files-dir" ereup-conf))
        (doc-files-dir (gethash "doc-files-dir" ereup-conf))
        (trimhex-dir (gethash "trimhex-dir" ereup-conf))
        (arch-exec (gethash "arch-exec" ereup-conf))
        (arch-params (gethash "arch-params" ereup-conf))
        (files)
        (new-remote-dir)
        (program-dir (file-name-directory load-file-name)))
    (if (and (file-exists-p remote-repo-dir)
             (file-exists-p (concat local-repo-dir "/" hex-files-dir))
             (file-exists-p (concat local-repo-dir "/" mpk-files-dir))
             (file-exists-p (concat local-repo-dir "/" doc-files-dir))
             (file-exists-p trimhex-dir))
        (progn
          (setq files (directory-files remote-repo-dir))
          (mapc (lambda (file-name)
                  (when (and (file-directory-p (concat remote-repo-dir "/" file-name))
                             (not (equal file-name "."))
                             (not (equal file-name "..")))
                    (cd remote-repo-dir)
                    (shell-command-to-string (concat arch-exec " " arch-params " "
                                                     file-name ".7z " file-name))
                    (delete-directory file-name t)
                    (cd program-dir) ) )
                files )
          (setq new-remote-dir (concat remote-repo-dir "/"
                                       local-repo-dir "__" (format-time-string "%Y-%m-%d_%H-%M")))
          (make-directory new-remote-dir)
          (copy-directory (concat local-repo-dir "/" hex-files-dir)
                          (concat new-remote-dir "/" hex-files-dir)
                          nil nil t)
          (copy-directory (concat local-repo-dir "/" mpk-files-dir)
                          (concat new-remote-dir "/" mpk-files-dir)
                          nil nil t)
          (copy-directory (concat local-repo-dir "/" doc-files-dir)
                          (concat new-remote-dir "/" doc-files-dir)
                          nil nil t) )
      (message " ereup ERROR => Directory not found! Please check local and remote repo directories, trimhex directory.") ) )
  (message " ereup -> Done.")
  )

(defun ereup-arch-repo ()
  "Archive repository."
  (message "\n ereup -> Archiving repository...")
  (shell-command-to-string (concat (gethash "arch-exec" ereup-conf) " "
                                   (gethash "arch-params" ereup-conf) " "
                                   (gethash "local-repo-dir" ereup-conf) "__"
                                   (format-time-string "%Y-%m-%d_%H-%M") ".7z "
                                   (gethash "local-repo-dir" ereup-conf)))
  (message " ereup -> Done.")
  )

(defun about ()
  "Show information about program."
  (message ereup-system-info)
  (message ereup-version)
  (message ereup-description)
  (message ereup-copyright)
  (message ereup-src-hosting)
  (message ereup-authors-blog)
  (message ereup-license)
  )

;;;; main

(let ((tasks)
      (work t))
  (message ereup-system-info)
  (message ereup-version)
  (ereup-init)
  (while work
    (ereup-show-menu)
    (message "Enter one or more tasks separated by whitespaces.")
    (setq tasks (read t))
    (mapc (lambda (curr-task)
            (cond ((equal curr-task 1)
                   (ereup-trim-hexes))
                  ((equal curr-task 3)
                   (ereup-arch-trimmed-hexes))
                  ((equal curr-task 4)
                   (ereup-upd-eng-descr-file))
                  ((equal curr-task 5)
                   (ereup-add-new-to-repo))
                  ((equal curr-task 6)
                   (ereup-clean-dir))
                  ((equal curr-task 7)
                   (ereup-publish-repo))
                  ((equal curr-task 8)
                   (ereup-arch-repo))
                  ((equal curr-task 9)
                   (about))
                  ((equal curr-task 0)
                   (progn
                     (setq work nil)
                     (message "\nBye!\n") ) )
                  (t
                   (message "Wrong task!")) ) )
          tasks ) )
  )
