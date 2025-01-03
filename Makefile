# This file is provided under a dual BSD/GPLv2 license.When using or
# redistributing this file, you may do so under either license.

# GPL LICENSE SUMMARY

# Copyright(c) 2015 Intel Corporation.

# This program is free software; you can redistribute it and/or modify
# it under the terms of version 2 of the GNU General Public License as
# published by the Free Software Foundation.

# This program is distributed in the hope that it will be useful, but
# WITHOUT ANY WARRANTY; without even the implied warranty of
# MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.See the GNU
# General Public License for more details.

# Contact Information:
# SoC Watch Developer Team <socwatchdevelopers@intel.com>
# Intel Corporation,
# 1300 S Mopac Expwy,
# Austin, TX 78746

# BSD LICENSE

# Copyright(c) 2015 Intel Corporation.

# Redistribution and use in source and binary forms, with or without
# modification, are permitted provided that the following conditions
# are met:

# * Redistributions of source code must retain the above copyright
# notice, this list of conditions and the following disclaimer.
# * Redistributions in binary form must reproduce the above copyright
# notice, this list of conditions and the following disclaimer in
# the documentation and/or other materials provided with the
# distribution.
# * Neither the name of Intel Corporation nor the names of its
# contributors may be used to endorse or promote products derived
# from this software without specific prior written permission.

# THIS SOFTWARE IS PROVIDED BY THE COPYRIGHT HOLDERS AND CONTRIBUTORS
# "AS IS" AND ANY EXPRESS OR IMPLIED WARRANTIES, INCLUDING, BUT NOT
# LIMITED TO, THE IMPLIED WARRANTIES OF MERCHANTABILITY AND FITNESS FOR
# A PARTICULAR PURPOSE ARE DISCLAIMED. IN NO EVENT SHALL THE COPYRIGHT
# OWNER OR CONTRIBUTORS BE LIABLE FOR ANY DIRECT, INDIRECT, INCIDENTAL,
# SPECIAL, EXEMPLARY, OR CONSEQUENTIAL DAMAGES (INCLUDING, BUT NOT
# LIMITED TO, PROCUREMENT OF SUBSTITUTE GOODS OR SERVICES; LOSS OF USE,
# DATA, OR PROFITS; OR BUSINESS INTERRUPTION) HOWEVER CAUSED AND ON ANY
# THEORY OF LIABILITY, WHETHER IN CONTRACT, STRICT LIABILITY, OR TORT
# (INCLUDING NEGLIGENCE OR OTHERWISE) ARISING IN ANY WAY OUT OF THE USE
# OF THIS SOFTWARE, EVEN IF ADVISED OF THE POSSIBILITY OF SUCH DAMAGE.

ifeq ($(DO_DEBUG_BUILD),)
    DO_DEBUG_BUILD := "1"
endif
INCDIR_1=$(COMMON_INC_DIR)
INCDIR_2=$(PWD)/inc

EXTRA_CFLAGS:=-I$(INCDIR_1)
EXTRA_CFLAGS += -I$(INCDIR_2)

EXTRA_CFLAGS += -DDO_DRIVER_PROFILING=$(DO_PROFILING)

EXTRA_CFLAGS += -Werror=strict-prototypes
EXTRA_CFLAGS += -Werror=pointer-to-int-cast
EXTRA_CFLAGS += -Werror=int-to-pointer-cast
EXTRA_CFLAGS += -Werror=format
EXTRA_CFLAGS += -Werror=attributes
EXTRA_CFLAGS += -Wframe-larger-than=2048
ifeq ($(DO_DEBUG_BUILD),1)
    EXTRA_CFLAGS += -Werror
endif

ifeq ($(CPUFREQ_FIX_BACKPORTED),1)
    EXTRA_CFLAGS += -DCPUFREQ_FIX_BACKPORTED
endif

KBUILD_EXTRA_SYMBOLS:=$(MODULE_SYMVERS_FILE)

obj-m := socwatch2_15.o

socwatch2_15-objs := ./src/sw_driver.o \
	./src/sw_hardware_io.o \
	./src/sw_output_buffer.o \
	./src/sw_tracepoint_handlers.o \
	./src/sw_collector.o \
	./src/sw_mem.o \
	./src/sw_internal.o \
	./src/sw_file_ops.o \
	./src/sw_ops_provider.o \
	./src/sw_trace_notifier_provider.o \
	./src/sw_reader.o \
	./src/sw_telem.o \
	./src/sw_pmt.o \
	./src/sw_counter_list.o \
	./src/sw_pci.o

.PHONY: kernel_check

kernel_check:
ifeq "$(KERNEL_SRC_DIR)" ""
	@echo "Error: makefile MUST NOT be invoked directly! Use the \"build_driver\" script instead."
	@exit 255
endif

default: kernel_check
	@echo "************************************************************"
	@echo "KERNEL_SRC_DIR=$(KERNEL_SRC_DIR)"
	@echo "CPUFREQ_FIX_BACKPORTED=$(CPUFREQ_FIX_BACKPORTED)"
	@echo "MODULE_SYMVERS_FILE=$(MODULE_SYMVERS_FILE)"
	@echo "DO_DRIVER_PROFILING=$(DO_PROFILING)"
	@echo "INCDIR_1=$(INCDIR_1)"
	@echo "************************************************************"
	make -C $(KERNEL_SRC_DIR) M=$(PWD) modules PWD=$(PWD)

clean: kernel_check
	make -C $(KERNEL_SRC_DIR) M=$(PWD) clean

modules_install: default
	make -C $(KERNEL_SRC_DIR) M=$(PWD) modules_install
