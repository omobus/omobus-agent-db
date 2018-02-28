# This file is a part of the omobus-agent-db project.
# Copyright (c) 2006 - 2018 ak-obs, Ltd. <info@omobus.net>.
# Author: Igor Artemov <i_artemov@ak-obs.ru>.

PACKAGE_NAME 	= omobus-agent-db
PACKAGE_VERSION = 3.4.2
COPYRIGHT 	= Copyright (c) 2006 - 2018 ak obs, ltd. <info@omobus.net>
SUPPORT 	= Support and bug reports: <support@omobus.net>
AUTHOR		= Author: Igor Artemov <i_artemov@ak-obs.ru>
BUGREPORT	= support@omobus.net

INSTALL		= install
RM		= rm -f
CP		= cp
TAR		= tar -cf
BZIP		= bzip2

DISTR_NAME	= $(PACKAGE_NAME)-$(PACKAGE_VERSION)

distr:
	$(INSTALL) -d $(DISTR_NAME)
	$(INSTALL) -m 0644 *.xconf *.conf *.sql Makefile* ChangeLog AUTHO* COPY* README* ./$(DISTR_NAME)
	$(CP) -r connections/ ./$(DISTR_NAME)/connections
	$(CP) -r transactions/ ./$(DISTR_NAME)/transactions
	$(CP) -r kernels/ ./$(DISTR_NAME)/kernels
	$(CP) -r queries/ ./$(DISTR_NAME)/queries
	$(CP) -r queries/ ./$(DISTR_NAME)/crond
	$(CP) -r queries/ ./$(DISTR_NAME)/systemd
	$(TAR) ./$(DISTR_NAME).tar ./$(DISTR_NAME)
	$(BZIP) ./$(DISTR_NAME).tar
	$(RM) -f -r ./$(DISTR_NAME)
