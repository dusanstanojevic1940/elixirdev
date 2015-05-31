defmodule Infinityloop.PageController do
  use Infinityloop.Web, :controller

  plug :action

  def index(conn, _params) do
    render conn, "index.html"
  end

  def sample_query do
	    query = from w in Item,
	          where: w.id_analyze == 0,
	         select: w
	    Repo.all(query)
	  end
    


  def info(conn, %{"user"=>user, "repo"=>repo, "email"=>email}) do
    
    id = user <> repo
    
    IO.puts(sample_query())
	render conn, "info.html", %{:id => id}
  end 



  def analyze(conn, %{"id"=>id}) do
  	res = Infinityloop.ItemController.findAll(id)
    render conn, "analyze.html", %{:response=>res}
  end

end