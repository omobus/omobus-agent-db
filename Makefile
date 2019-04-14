# Copyright (c) 2006 - 2019 omobus-agent-db authors, see the included COPYRIGHT file.

PACKAGE_NAME 	= omobus-agent-db
PACKAGE_VERSION = 3.4.8
COPYRIGHT 	= Copyright (c) 2006 - 2019 ak obs, ltd. <info@omobus.net>
SUPPORT 	= Support and bug reports: <support@omobus.net>
AUTHOR		= Author: Igor Artemov <i_artemov@ak-obs.ru>
BUGREPORT	= support@omobus.net
DISTR_NAME	= $(PACKAGE_NAME)-$(PACKAGE_VERSION)

all:
	@echo "$(DISTR_NAME)"
	@echo "$(COPYRIGHT)"
	@echo "$(SUPPORT)"
