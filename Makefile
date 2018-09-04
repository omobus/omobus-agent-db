# This file is a part of the omobus-agent-db project.
# Copyright (c) 2006 - 2018 ak-obs, Ltd. <info@omobus.net>.
# Author: Igor Artemov <i_artemov@ak-obs.ru>.

PACKAGE_NAME 	= omobus-agent-db
PACKAGE_VERSION = 3.4.3
COPYRIGHT 	= Copyright (c) 2006 - 2018 ak obs, ltd. <info@omobus.net>
SUPPORT 	= Support and bug reports: <support@omobus.net>
AUTHOR		= Author: Igor Artemov <i_artemov@ak-obs.ru>
BUGREPORT	= support@omobus.net
DISTR_NAME	= $(PACKAGE_NAME)-$(PACKAGE_VERSION)

all:
	@echo "$(DISTR_NAME)"
	@echo "$(COPYRIGHT)"
	@echo "$(SUPPORT)"
