PROJECT_NAME := $(notdir $(CURDIR))
TIMESTAMP := $(shell date +%s)
TEMP_DIR := /tmp/NeoServ-$(TIMESTAMP)
MAIN_DIR = ./src
DIST_DIR = ./dist
CONFIG_DIR := ./lb_configs
TEMP_ARCHIVE_NAME := $(TIMESTAMP).tar.gz
MAIN_ARCHIVE_NAME := neoserv.tar.gz
MAIN_UPDATE_ARCHIVE_NAME := update.tar.gz
MAIN_ARCHIVE_INSTALLER := NeoServ.zip
LB_ARCHIVE_NAME := loadbalancer.tar.gz
LB_UPDATE_ARCHIVE_NAME := loadbalancer_update.tar.gz
DELETED_LIST := ${DIST_DIR}/deleted_files.txt
LAST_TAG := $(shell curl -s https://api.github.com/repos/xneoserv/NeoServ/releases/latest | grep '"tag_name":' | sed -E 's/.*"([^"]+)".*/\\1/')
HASH_FILE := hashes.md5

# Directories and files to exclude (can be easily edited)
EXCLUDES := \
	.git

# Files and directories to copy from MAIN to LB
LB_FILES := bin config content crons includes signals tmp www status update service

# Directories to remove from LB
LB_DIRS_TO_REMOVE := \
	bin/install \
	bin/redis \
	includes/langs \
	includes/api \
	includes/libs/resources \
	bin/nginx/conf/codes

# Files to remove from LB
LB_FILES_TO_REMOVE := \
	bin/maxmind/GeoLite2-City.mmdb \
	crons/backups.php \
	crons/cache_engine.php \
	includes/admin_api.php \
	includes/admin.php \
	includes/reseller_api.php \
	www/xplugin.php \
	www/probe.php \
	www/playlist.php \
	www/player_api.php \
	www/epg.php \
	www/enigma2.php \
	www/stream/auth.php \
	www/admin/proxy_api.php \
	www/admin/api.php \
	config/rclone.conf \
	crons/epg.php \
	crons/update.php \
	crons/providers.php \
	crons/root_mysql.php \
	crons/series.php \
	crons/tmdb.php \
	crons/tmdb_popular.php \
	includes/cli/migrate.php \
	includes/cli/cache_handler.php \
	includes/cli/balancer.php \
	bin/nginx/conf/gzip.conf

EXCLUDE_ARGS := $(addprefix --exclude=,$(EXCLUDES))

.PHONY: new lb main main_update lb_update lb_copy_files lb_update_copy_files main_copy_files main_update_copy_files set_permissions create_archive lb_archive_move lb_update_archive_move main_archive_move main_update_archive_move main_install_archive clean delete_files_list

lb: lb_copy_files set_permissions create_archive lb_archive_move clean
main: main_copy_files set_permissions create_archive main_archive_move main_install_archive clean
main_update: main_update_copy_files set_permissions create_archive main_update_archive_move clean
lb_update: lb_update_copy_files set_permissions create_archive lb_update_archive_move clean

lb_copy_files:
	@echo "==> [LB] Creating distribution directory: $(DIST_DIR)"
	@mkdir -p ${DIST_DIR}
	@echo "==> [LB] Creating temporary directory: $(TEMP_DIR)"
	@mkdir -p ${TEMP_DIR}

	@echo "==> [LB] Copying files from MAIN_DIR"
	@for item in $(LB_FILES); do \
		echo "   → Copying: $$item"; \
		cp -r "$(MAIN_DIR)/$$item" "$(TEMP_DIR)"; \
	done

	@echo "==> [LB] Removing excluded directories"
	@for dir in $(LB_DIRS_TO_REMOVE); do \
		echo "   → Removing directory: $$dir"; \
		rm -rf "$(TEMP_DIR)/$$dir"; \
	done

	@echo "==> [LB] Removing excluded files"
	@for file in $(LB_FILES_TO_REMOVE); do \
		echo "   → Removing file: $$file"; \
		rm -f "$(TEMP_DIR)/$$file"; \
	done

	@echo "==> [LB] Copying config files"
	cp "$(CONFIG_DIR)/nginx.conf" $(TEMP_DIR)/bin/nginx/conf/nginx.conf
	cp "$(CONFIG_DIR)/live.conf" $(TEMP_DIR)/bin/nginx_rtmp/conf/live.conf

	@echo "Remove all .gitkeep files..."
	@find $(TEMP_DIR) -name .gitkeep \
		-not -path "*/.git/*" \
		-delete
	@echo "All files gitkeep deleted"

lb_update_copy_files:
	@echo "[INFO] Using last tag: $(LAST_TAG)"
	@echo "[INFO] Checking for changes in 'src/' from $(LAST_TAG) to HEAD..."

	@echo "[INFO] Preparing output directories"
	@mkdir -p $(DIST_DIR)
	@mkdir -p $(TEMP_DIR)

	@echo "[INFO] Copying modified or added files from 'src/' that are in LB_FILES..."
	@for file in $$(git diff --name-only --diff-filter=AMR $(LAST_TAG)..HEAD | grep '^src/'); do \
		rel_path=$$(echo "$$file" | sed 's|^src/||'); \
		allowed=0; \
		for lb_item in $(LB_FILES); do \
			if echo "$$rel_path" | grep -q "^$$lb_item/"; then \
				allowed=1; \
				break; \
			fi; \
		done; \
		if [ "$$allowed" -eq 1 ] && [ -f "$$file" ]; then \
			echo "[COPY] $$file -> $(TEMP_DIR)/$$rel_path"; \
			mkdir -p "$(TEMP_DIR)/$$(dirname $$rel_path)"; \
			cp "$$file" "$(TEMP_DIR)/$$rel_path"; \
		else \
			echo "[SKIP] $$file (not in LB_FILES)"; \
		fi \
	done

	@echo "==> [LB] Removing excluded directories"
	@for dir in $(LB_DIRS_TO_REMOVE); do \
		echo "   → Removing directory: $$dir"; \
		rm -rf "$(TEMP_DIR)/$$dir"; \
	done

	@echo "==> [LB] Removing excluded files"
	@for file in $(LB_FILES_TO_REMOVE); do \
		echo "   → Removing file: $$file"; \
		rm -f "$(TEMP_DIR)/$$file"; \
	done

	@echo "Remove all .gitkeep files..."
	@find $(TEMP_DIR) -name .gitkeep \
		-not -path "*/.git/*" \
		-delete
	@echo "All files gitkeep deleted"

main_copy_files:
	@echo "==> [MAIN] Creating distribution directory: $(DIST_DIR)"
	mkdir -p ${DIST_DIR}
	@echo "==> [MAIN] Creating temporary directory: $(TEMP_DIR)"
	mkdir -p $(TEMP_DIR)

	@echo "==> [MAIN] Copying files from $(MAIN_DIR)"
	@if command -v rsync >/dev/null 2>&1; then \
		echo "   → Using rsync..."; \
		rsync -a $(EXCLUDE_ARGS) $(MAIN_DIR)/ $(TEMP_DIR)/; \
	else \
		echo "⚠️  rsync not found, falling back to tar..."; \
		tar cf - $(EXCLUDE_ARGS) -C $(MAIN_DIR) . | tar xf - -C $(TEMP_DIR); \
	fi

	@echo "Remove all .gitkeep files..."
	@find $(TEMP_DIR) -name .gitkeep \
		-not -path "*/.git/*" \
		-delete
	@echo "All files gitkeep deleted"

main_update_copy_files:
	@echo "[INFO] Using last tag: $(LAST_TAG)"
	@echo "[INFO] Checking for changes in 'src/' from $(LAST_TAG) to HEAD..."

	@echo "[INFO] Preparing output directories"
	@mkdir -p $(DIST_DIR)
	@mkdir -p $(TEMP_DIR)

	@echo "[INFO] Copying modified or added files from 'src/'..."
	@for file in $$(git diff --name-only --diff-filter=AMR $(LAST_TAG)..HEAD | grep '^src/'); do \
		rel_path=$$(echo "$$file" | sed 's|^src/||'); \
		if [ -f "$$file" ]; then \
			echo "[COPY] $$file -> $(TEMP_DIR)/$$rel_path"; \
			mkdir -p "$(TEMP_DIR)/$$(dirname "$$rel_path")"; \
			cp "$$file" "$(TEMP_DIR)/$$rel_path"; \
		fi \
	done

	@echo "Remove all .gitkeep files..."
	@find $(TEMP_DIR) -name .gitkeep \
		-not -path "*/.git/*" \
		-delete
	@echo "All files gitkeep deleted"

delete_files_list:
	@rm -f $(DELETED_LIST)

	@echo "[INFO] Writing list of deleted files from 'src/' to $(DELETED_LIST)"
	@git diff --name-status $(LAST_TAG)..HEAD | grep '^D' | cut -f2 | grep '^src/' | sed 's|^src/||' | \
	while read file; do \
		echo "if (file_exists(MAIN_HOME . '$$file')) {"; \
		echo "    unlink(MAIN_HOME . '$$file');"; \
		echo "}"; \
	done > $(DELETED_LIST)

	@echo "[INFO] Deleted files cleanup code:"
	@cat $(DELETED_LIST)

set_permissions:
	@echo "==> Setting file and directory permissions"
	@if [ -d "$(TEMP_DIR)/admin" ]; then \
		find "$(TEMP_DIR)/admin" -type d -exec chmod 755 {} +; \
		find "$(TEMP_DIR)/admin" -type f -exec chmod 644 {} +; \
	fi
	# (ostali chmod bloki pustiš enake kot v tvoji izvirni datoteki)

create_archive:
	@echo "==> Creating final archive: ${TEMP_ARCHIVE_NAME}"
	@tar -czf ${DIST_DIR}/${TEMP_ARCHIVE_NAME} -C $(TEMP_DIR) .

lb_archive_move:
	@echo "==> Moving LB archive to: ${DIST_DIR}/${LB_ARCHIVE_NAME}"
	@rm -f ${DIST_DIR}/${LB_ARCHIVE_NAME}
	@mv ${DIST_DIR}/${TEMP_ARCHIVE_NAME} ${DIST_DIR}/${LB_ARCHIVE_NAME}
	md5sum "${DIST_DIR}/${LB_ARCHIVE_NAME}" | awk -v name="${LB_ARCHIVE_NAME}" '{print $$1, name}' >> "${DIST_DIR}/${HASH_FILE}"

lb_update_archive_move:
	@echo "==> Moving LB update archive to: ${DIST_DIR}/${LB_UPDATE_ARCHIVE_NAME}"
	@rm -f ${DIST_DIR}/${LB_UPDATE_ARCHIVE_NAME}
	@mv ${DIST_DIR}/${TEMP_ARCHIVE_NAME} ${DIST_DIR}/${LB_UPDATE_ARCHIVE_NAME}
	md5sum "${DIST_DIR}/${LB_UPDATE_ARCHIVE_NAME}" | awk -v name="${LB_UPDATE_ARCHIVE_NAME}" '{print $$1, name}' >> "${DIST_DIR}/${HASH_FILE}"

main_archive_move:
	@echo "==> Moving MAIN archive to: ${DIST_DIR}/${MAIN_ARCHIVE_NAME}"
	@rm -f ${DIST_DIR}/${MAIN_ARCHIVE_NAME}
	@mv ${DIST_DIR}/${TEMP_ARCHIVE_NAME} ${DIST_DIR}/${MAIN_ARCHIVE_NAME}

main_update_archive_move:
	@echo "==> Moving MAIN update archive to: ${DIST_DIR}/${MAIN_UPDATE_ARCHIVE_NAME}"
	@rm -f ${DIST_DIR}/${MAIN_UPDATE_ARCHIVE_NAME}
	@mv ${DIST_DIR}/${TEMP_ARCHIVE_NAME} ${DIST_DIR}/${MAIN_UPDATE_ARCHIVE_NAME}
	md5sum "${DIST_DIR}/${MAIN_UPDATE_ARCHIVE_NAME}" | awk -v name="${MAIN_UPDATE_ARCHIVE_NAME}" '{print $$1, name}' >> "${DIST_DIR}/${HASH_FILE}"

main_install_archive:
	@echo "==> Creating installer archive: ${DIST_DIR}/${MAIN_ARCHIVE_INSTALLER}"
	@rm -f ${DIST_DIR}/${MAIN_ARCHIVE_INSTALLER}
	@zip -r ${DIST_DIR}/${MAIN_ARCHIVE_INSTALLER} install && zip -j ${DIST_DIR}/${MAIN_ARCHIVE_INSTALLER} ${DIST_DIR}/${MAIN_ARCHIVE_NAME}
	@echo "==> Remove archive: ${DIST_DIR}/${MAIN_ARCHIVE_NAME}"
	rm -rf ${DIST_DIR}/${MAIN_ARCHIVE_NAME}

clean:
	@echo "==> Cleaning up temporary directory: $(TEMP_DIR)"
	@rm -rf $(TEMP_DIR)
	@echo "✅ Project build complete"

new:
	@echo "==> Cleaning up temporary directory: $(DIST_DIR)"
	@rm -rf $(DIST_DIR)
	@echo "==> [LB] Creating distribution directory: $(DIST_DIR)"
	@mkdir -p ${DIST_DIR}
