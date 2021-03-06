
class MoviesController < ApplicationController
  before_action :set_movie, only: %i[ show edit update destroy ]
  skip_before_action :verify_authenticity_token
  # GET /movies or /movies.json
  def index
    @movies = Movie.all
  end

  # GET /movies/1 or /movies/1.json
  def show
    if @movie.imdbID != ''
      omdbapi = Omdbapi.new
      result = omdbapi.GetMovieById(@movie.imdbID)
      if result
        @api_result = result
      end
    end
  end

  # GET /movies/new
  def new
    @movie = Movie.new
    @header = "Opret film"
  end

  # GET /movies/1/edit
  def edit
    @header = "Rediger film"
    if(@movie.imdbID != "")
      omdbapi = Omdbapi.new
      @api_result = omdbapi.GetMovieById(@movie.imdbID)
    end
  end

  # POST /movies or /movies.json
  def create
    @movie = Movie.new(movie_params)

    if @movie.title != ''
      omdbapi = Omdbapi.new
      result = omdbapi.GetMovie(@movie.title)
      if result.error == nil
        @movie.imdbID = result.imdb_id
        @api_result = result
      end
    end

      respond_to do |format|
        if @movie.save
          format.html { redirect_to @movie, notice: 'Movie was successfully created.' }
          format.json { render :show, status: :created, location: @movie }
        else
          format.html { render :new, status: :unprocessable_entity }
          format.json { render json: @movie.errors, status: :unprocessable_entity }
        end
      end
  end

  # PATCH/PUT /movies/1 or /movies/1.json
  def update
    attributes = movie_params.clone
    if movie_params['title'] != ''
      omdbapi = Omdbapi.new 
      result = omdbapi.GetMovie(movie_params['title'])
      if result.error == nil
        attributes['imdbID'] = result.imdb_id 
        @api_result = result
      else
        attributes['imdbID'] = ''
      end
    end

    respond_to do |format|
      if @movie.update(attributes)
        format.html { redirect_to @movie, notice: 'Movie was successfully updated.' }
        format.json { render :show, status: :ok, location: @movie }
      else
        format.html { render :edit, status: :unprocessable_entity }
        format.json { render json: @movie.errors, status: :unprocessable_entity }
      end
    end
  end

  # DELETE /movies/1 or /movies/1.json
  def destroy
    @movie.destroy
    respond_to do |format|
      format.html { redirect_to movies_url, notice: 'Movie was successfully destroyed.' }
      format.json { head :no_content }
    end
  end

  private
  # Use callbacks to share common setup or constraints between actions.
  def set_movie
    @movie = Movie.find(params[:id])
  end

  # Only allow a list of trusted parameters through.
  def movie_params
    params.require(:movie).permit(:title, :description, :imdbID, :image)
  end
end
