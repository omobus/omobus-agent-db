# This file is a part of the omobus-agent-db project.
# Copyright (c) 2006 - 2016 ak-obs, Ltd. <info@omobus.net>.
# Author: Igor Artemov <i_artemov@ak-obs.ru>.

PACKAGE_NAME 	= omobus-agent-db
PACKAGE_VERSION = 3.3.6
COPYRIGHT 	= Copyright (c) 2006 - 2016 ak obs, ltd. <info@omobus.net>
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
	$(INSTALL) -m 0644 *.xconf *.conf *.sql *.ldif omobus-agentd.* Makefile* ChangeLog AUTHO* COPY* README* ./$(DISTR_NAME)
	$(CP) -r connections/ ./$(DISTR_NAME)
	$(CP) -r transactions/ ./$(DISTR_NAME)
	$(CP) -r kernels/ ./$(DISTR_NAME)
	$(CP) -r queries/ ./$(DISTR_NAME)
	$(TAR) ./$(DISTR_NAME).tar ./$(DISTR_NAME)
	$(BZIP) ./$(DISTR_NAME).tar
	$(RM) -f -r ./$(DISTR_NAME)
