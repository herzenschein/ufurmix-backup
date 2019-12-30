#!/usr/bin/python
#
# Copyright (C) 2007-2008 Canonical Ltd.
#
# This program is free software; you can redistribute it and/or modify
# it under the terms of the GNU General Public License as published by
# the Free Software Foundation; either version 2 of the License, or
# (at your option) any later version.
#
# This program is distributed in the hope that it will be useful,
# but WITHOUT ANY WARRANTY; without even the implied warranty of
# MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
# GNU General Public License for more details.
#
# You should have received a copy of the GNU General Public License along
# with this program; if not, write to the Free Software Foundation, Inc.,
# 51 Franklin Street, Fifth Floor, Boston, MA 02110-1301 USA.
#


import threading
import nppapt
import sqlite3
import sys

if len(sys.argv) < 3:
	print "CMD <release> <archs>"
	sys.exit(2)

releases=sys.argv[1]
archs=sys.argv[2]

print "RELEASES", releases

mimetype_pkgweights = { "application/x-shockwave-flash" : { "flashplugin-nonfree" : 9, "flashplugin-installer" : 9 } }	

class AptPluginDbUpdater:

	def __init__ (self, apt_con, configroot):
		self._apt_con = apt_con
		self._configroot = configroot

	def redo_arch_rel_data (self, architecture, rel, entries):
		self._apt_con.execute('delete from package where architecture=? AND distribution=?', (architecture, rel))
		for e in entries:
			pkgweight = 0
			if e.mimetype in mimetype_pkgweights and e.pkgname in mimetype_pkgweights [ e.mimetype ]:
				pkgweight = mimetype_pkgweights [ e.mimetype ] [ e.pkgname ]

			print "insert into package (pkgname, pkgdesc, pkglongdesc, name, mimetype, architecture, appid, distribution, section, weight, filehint, description) values (?,?,?,?,?,?,\"{"+e.app_id.strip()+"}\",?,?,?,?,?)", \
			e.pkgname, e.pkgdesc, e.pkglongdesc, e.name, e.mimetype, architecture, e.distribution, e.section, pkgweight, e.filehint, e.description

			try:
				self._apt_con.execute("insert into package (pkgname, pkgdesc, pkglongdesc, name, mimetype, architecture, appid, distribution, section, weight, filehint, description) values (?,?,?,?,?,?,\"{"+e.app_id.strip()+"}\",?,?,?,?,?)", \
					(e.pkgname, e.pkgdesc, e.pkglongdesc, e.name, e.mimetype, architecture, e.distribution, e.section, pkgweight, e.filehint, e.description))
				print " ... inserted ... "
			except Exception, e:
				print "ERROR", e.args


	def geterror (self):
		return self._error

	def run(self):
		i = 0
		apttmproot = None
		try:
			self._apt_con.execute( \
				"CREATE TABLE package " + \
				"( id integer PRIMARY KEY," + \
				"  pkgname string NOT NULL," + \
				"  pkgdesc strong NOT NULL," + \
				"  pkglongdesc string NOT NULL," + \
				"  name string NOT NULL," + \
				"  mimetype string NOT NULL," + \
				"  architecture string NULL," + \
				"  appid string NOT NULL," + \
				"  distribution string NOT NULL," + \
				"  section string NOT NULL," + \
				"  weight integer NOT NULL," + \
				"  filehint integer NOT NULL," + \
				"  description integer NOT NULL," + \
				"  UNIQUE (pkgname, architecture, appid, mimetype, distribution)" + \
				");")

		except:
			print "table already exists?"

		try:
			apttmproot=nppapt.setup_tmp_cache_tree(self._configroot)

			arch_arr = archs.split(" ")
			rel_arr = releases.split(" ")
			for architecture in arch_arr:
				for rel in rel_arr:
					npp_info_entries = nppapt.get_npp_entries_for_arch_and_distribution(apttmproot, architecture, rel)
					self.redo_arch_rel_data(architecture, rel, npp_info_entries)
		finally:
			if not apttmproot is None:
				nppapt.tear_down_tmp_cache(apttmproot)






dbfile="/tmp/apt-plugins.sqlite"
apt_con = sqlite3.connect(dbfile)
updater = AptPluginDbUpdater(apt_con, "./")
updater.run()
apt_con.commit() 
apt_con.close()
