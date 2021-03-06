class Surname < ActiveRecord::Base
  validates :name, :presence => true
  validate :ensure_name_is_kanji_only
  attr_accessor :large_graph_char_data, :large_graph_nodes, :large_graph_names, :small_graph_names

  def self.histogram_data
    names = self.pluck(:name)
    kanji = names.join("").split("")
    hash = kanji.group_by { |v| v }
    result = hash.map{|key, value| {:kanji => key, :value => value.count}}.sort_by { |hsh| hsh[:value] }.reverse
  end

  def self.large_graph_data
    { nodes: self.large_graph_nodes, 
      links: self.large_graph_links }
  end

  def self.small_graph_data
    { nodes: self.small_graph_nodes, 
      links: self.small_graph_links }
  end

  def self.nodes
    kanji_array = self.pluck(:name).join("").split("").uniq
    kanji_array.each_with_index.map do |name, index| 
      { name: name, 
        id: index, 
        meaning: Character.find_by(:name => name).meaning }
    end
  end

  def self.links
    nodes = self.nodes.map {|hsh| hsh[:name] }
    self.pluck(:name).map { |name| { source: nodes.index(name[0]),
                                     target: nodes.index(name[1]) } }
  end

  def self.small_graph_names
    @small_graph_names ||= self.limit(10).pluck(:name)
  end

  def self.large_graph_names
    @large_graph_names ||= self.all.pluck(:name)
  end

  def self.small_graph_nodes
    kanji_array = self.small_graph_names.join("").split("").uniq
    kanji_array.each_with_index.map do |name, index| 
      { name: name,
        id: index,
        meaning: Character.find_by(:name => name).meaning }
    end
  end

  # previous version
  def self.busted_large_graph_nodes
    kanji_array = self.large_graph_names.join("").split("").uniq
    kanji_array.each_with_index.map do |name, index| 
      { name: name,
        id: index,
        meaning: Character.find_by(:name => name).meaning }
    end
  end

  def self.get_large_graph_chars(kanji_array)
    @large_graph_char_data ||= Character.where(:name => kanji_array)
  end


  def self.large_graph_nodes
    kanji_array = self.large_graph_names.join("").split("").uniq
    all_characters = get_large_graph_chars(kanji_array)
    all_characters.each_with_index.map do |char_data, index|
      {name: char_data.name,
       id: index,
       meaning: char_data.meaning
      }
    end
  end

  def self.small_graph_links
    # nodes = self.small_graph_nodes.map {|hsh| hsh[:name] }
    # self.limit(10).pluck(:name).map { |name| { source: nodes.index(name[0]),
    #                                 target: nodes.index(name[1]) } }
    nodes_with_ids = self.small_graph_names.map{ |name| {source: self.small_graph_nodes.select{|hsh| hsh[:name] == name[0]}[0][:id],
                                                         target: self.small_graph_nodes.select{|hsh| hsh[:name] == name[1]}[0][:id]}}
  end

  def self.large_graph_links
    nodes_with_ids = self.large_graph_names.map{ |name| {source: self.large_graph_nodes.select{|hsh| hsh[:name] == name[0]}[0][:id],
                                                         target: self.large_graph_nodes.select{|hsh| hsh[:name] == name[1]}[0][:id]}}
  end


  def self.edges
    self.links.collect{|hsh| [hsh[:source], hsh[:target]].sort}
  end

  def self.small_graph_edges
    self.small_graph_links.collect{|hsh| [hsh[:source], hsh[:target]].sort}
  end

  def self.large_graph_edges
    self.large_graph_links.collect{|hsh| [hsh[:source], hsh[:target]].sort}
  end

  def self.components
    edges = self.edges
    components = []
    while edges.any? 
      component = edges.shift
      while edges.select { |edge| !(edge & component).empty? }.any?

        component << edges.select { |edge| !(edge & component).empty? }
        edges.delete_if { |edge| !(edge & component).empty? }
        component = component.flatten.uniq
      end
      components << component
    end
    components
  end

  def self.small_graph_components
    edges = self.small_graph_edges
    components = []
    while edges.any? 
      component = edges.shift
      while edges.select { |edge| !(edge & component).empty? }.any?
        component << edges.select { |edge| !(edge & component).empty? }
        edges.delete_if { |edge| !(edge & component).empty? }
        component = component.flatten.uniq
      end
      components << component
    end
    components
  end

  def self.large_graph_components
    edges = self.large_graph_edges
    components = []
    while edges.any? 
      component = edges.shift
      while edges.select { |edge| !(edge & component).empty? }.any?
        component << edges.select { |edge| !(edge & component).empty? }
        edges.delete_if { |edge| !(edge & component).empty? }
        component = component.flatten.uniq
      end
      components << component
    end
    components
  end

  def ensure_name_is_kanji_only
    if self.name.chars.any? { |char| char.ord < 19968 || char.ord > 40879 || char.ord == 12293 }
      errors.add(:name, "must be in kanji.")
    end
  end
end
