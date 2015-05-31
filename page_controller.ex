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
    """
    Infinityloop.ItemController.deleteByAnalyzeId(conn, id);

  	task = Task.async(fn -> 
  		repository = HTTPotion.get "https://api.github.com/repos/"<>user<>"/"<>repo<>"/git/trees/master?recursive=1", [body: "", headers: ["User-Agent": "My App"]]	
	  	
	  	{:ok, globalResponseJSON} = JSON.decode(repository.body)
	  	Enum.each(globalResponseJSON["tree"], fn e ->
			if String.contains?(e["path"], ".exs") or String.contains?(e["path"], ".ex") do  

				response = HTTPotion.get e["url"], [body: "", headers: ["User-Agent": "My App"]]	

		  		{:ok, responseJSON} = JSON.decode(response.body)
				
		  		decodedValue = Base.decode64(responseJSON["content"])

				functions = ElixirAnalysis.__info__(:functions)


				Enum.each(functions, fn {k, v} -> 	
					result = apply(ElixirAnalysis, k, [decodedValue])
				  	Infinityloop.ItemController.create(conn, [id, result])
				end)

				from = "infinite.hackathon@gmail.com"
				to = email
				subject = "Static Code Analysis"
				body = id
				server = "smtp.gmail.com"
				login = "infinite.hackathon@gmail.com"
				password = "infinityloop"
				ElixirSmtp.send!(from, to, subject, body, server, login, password)
				
			end
		end)
  	end)
	"""
	render conn, "info.html", %{:id => id}
  end 



  def analyze(conn, %{"id"=>id}) do
  	res = Infinityloop.ItemController.findAll(id)
    render conn, "analyze.html", %{:response=>res}
  end

end