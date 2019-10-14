require_relative "../config/environment.rb"
require 'active_support/inflector'

class InteractiveRecord

  def self.table_name
    self.to_s.downcase.pluralize
    #take the instance of table_name and covet to a string then downcase then plurize
  end

  def self.column_names
    DB[:conn].results_as_hash = true

    sql = "pragma table_info('#{table_name}')"

    table_info = DB[:conn].execute(sql)
    column_names = []
    table_info.each do |row|
      column_names << row["name"]
    end
    column_names.compact
    #pragma returns an array that describes it self of the table name
  end

  def initialize(options={})
    options.each do |property, value|
      self.send("#{property}=", value)
    end
    #takes an empty hash and puts property and val into it
  end

  def save
    sql = "INSERT INTO #{table_name_for_insert} (#{col_names_for_insert}) VALUES (#{values_for_insert})"
    DB[:conn].execute(sql)
    @id = DB[:conn].execute("SELECT last_insert_rowid() FROM #{table_name_for_insert}")[0][0]
    # put table_name colum_name and values and pand put them into the table
    #then thake the array of arrays at pos 0 and then at pos 0 and put that in
  end

  def table_name_for_insert
    self.class.table_name
    #take the table name get this have it in this method so it can be called on later
  end

  def values_for_insert
    values = []
    self.class.column_names.each do |col_name|
      values << "'#{send(col_name)}'" unless send(col_name).nil?
    end
    values.join(", ")
    #checking to see if there is a colum name if there is sholve it into values
  end

  def col_names_for_insert
    self.class.column_names.delete_if {|col| col == "id"}.join(", ")

  end

def self.find_by_name(name)
  sql = "SELECT * FROM #{self.table_name} WHERE name = ?"
  DB[:conn].execute(sql, name)
  # finding the the name where your looking for it (abstraction)
end

end
