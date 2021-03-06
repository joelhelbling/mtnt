require 'rubygems'
require 'sinatra'
require 'erb'

Dir[File.join(%w[. lib ** *.rb])].each { |f| require f }

get '/' do
  redirect to('/Matthew/1')
end

get %r{^/([A-Za-z0-9_]+)/(\d+)$} do |book, chapter|
  Book.clear_cache! if ENV['DEVELOPMENT']
  @title = "#{book} #{chapter}"
  @verses = Book[book.downcase][chapter.to_i]
  erb :chapter
end

get %r{^/(G\d+)$} do |id|
  @id = id
  @lexeme = Lexicon[id]
  @title = "#{id} #{@lexeme.lemma} = #{@lexeme.translation}"
  erb :lexeme
end

if ENV['DEVELOPMENT']
  get %r{^/(G\d+)/edit$} do |id|
    @id = id
    @lexeme = Lexicon[id]
    @title = "Edit #{id} #{@lexeme.lemma}"
    erb :lexeme_edit
  end

  put %r{^/(G\d+)$} do |id|
    @lexeme = Lexicon[id]
    @lexeme.pos = params[:pos].to_sym
    @lexeme.tags = (params[:tags] || []).map { |tag| tag.strip.to_sym }
    @lexeme.translation = params[:translation].strip
    @lexeme.gsubs = Lexicon.parse_gsubs(params[:gsubs].strip.gsub("\n", ' '))
    @lexeme.etymology = params[:etymology].strip.force_encoding('UTF-8')
    @lexeme.explanation = params[:explanation].strip.gsub("\n", ' ').force_encoding('UTF-8')
    @lexeme.quality = params[:quality].map(&:to_i) if params[:quality]
    Lexicon.save
    redirect to("/#{id}")
  end
end
