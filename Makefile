
 
status: ## Show containers status  
	docker ps
ps: ## Show containers status  
	docker ps

install_dependencies: ## Install all project dependencies
	@make create_env
	@make pip_install
 
create_env:  
	python3 -m venv venv_dbt
 
pip_install:  
	. ./venv_dbt/bin/activate
	venv_dbt/bin/pip install dbt-core dbt-trino  

start: ## Start Services
	docker compose -f devops/docker-compose.yaml up -d  

stop: ## Stop Services
	docker compose -f devops/docker-compose.yaml down  
debug:
	dbt debug --profiles-dir .dbt
clean:
	rm -rf venv target
 
#################################################################################
# Self Documenting Commands                                                     #
#################################################################################

.DEFAULT_GOAL := help

# Inspired by <http://marmelab.com/blog/2016/02/29/auto-documented-makefile.html>
# sed script explained:
# /^##/:
# 	* save line in hold space
# 	* purge line
# 	* Loop:
# 		* append newline + line to hold space
# 		* go to next line
# 		* if line starts with doc comment, strip comment character off and loop
# 	* remove target prerequisites
# 	* append hold space (+ newline) to line
# 	* replace newline plus comments by `---`
# 	* print line
# Separate expressions are necessary because labels cannot be delimited by
# semicolon; see <http://stackoverflow.com/a/11799865/1968>
.PHONY: help

                                                          

help:
	@echo '**************************************************************************'
	@echo ' '
                                                          
                                                          
	@echo 'TTTTTTTTTTTTTTTTTTTTTTT  iiii  kkkkkkkk             iiii  '
	@echo 'T:::::::::::::::::::::T i::::i k::::::k            i::::i '
	@echo 'T:::::::::::::::::::::T  iiii  k::::::k             iiii  '
	@echo 'T:::::TT:::::::TT:::::T        k::::::k                   '
	@echo 'TTTTTT  T:::::T  TTTTTTiiiiiii  k:::::k    kkkkkkkiiiiiii '
	@echo '        T:::::T        i:::::i  k:::::k   k:::::k i:::::i '
	@echo '        T:::::T         i::::i  k:::::k  k:::::k   i::::i '
	@echo '        T:::::T         i::::i  k:::::k k:::::k    i::::i '
	@echo '        T:::::T         i::::i  k::::::k:::::k     i::::i '
	@echo '        T:::::T         i::::i  k:::::::::::k      i::::i '
	@echo '        T:::::T         i::::i  k:::::::::::k      i::::i '
	@echo '        T:::::T         i::::i  k::::::k:::::k     i::::i '
	@echo '      TT:::::::TT      i::::::ik::::::k k:::::k   i::::::i'
	@echo '      T:::::::::T      i::::::ik::::::k  k:::::k  i::::::i'
	@echo '      T:::::::::T      i::::::ik::::::k   k:::::k i::::::i'
	@echo '      TTTTTTTTTTT      iiiiiiiikkkkkkkk    kkkkkkkiiiiiiii'
                                                          
            

	@echo ' ' 
	@echo '**************************************************************************'
	@echo '   '
	@echo Commands  
	@echo '   '
	@grep -E '^[a-zA-Z_-]+:.*?## .*$$' $(MAKEFILE_LIST) | sort | awk 'BEGIN {FS = ":.*?## "}; {printf "\033[36m%-30s\033[0m %s\n", $$1, $$2}'
