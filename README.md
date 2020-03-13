# Documentation generation

In order to re-generate the documentation:
1. docker build -t doc . 
2. docker run -it -v $(pwd):/doc -p 8000:8000 -e USER_ID=$UID doc make html