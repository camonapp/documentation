# Hi
 This project is made for centralize documentation


 # How to run
    You need to hace docker installed on your machine

  * First clone this repo and cd into it.
  * Run `docker build -t doc .`.
  * Then run `docker run -it -v $(pwd):/doc -p 8000:8000 -e USER_ID=$UID your_user make livehtml` -> to se your changes in local.
  * if you want to build your documentation run `docker run -it -v $(pwd):/doc -p 8000:8000 -e USER_ID=$UID your_user make html`.
  
