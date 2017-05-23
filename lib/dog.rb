require 'pry'

class Dog

  attr_accessor :name, :breed, :id

  def initialize(name: name, breed: breed, id: nil)
    @name = name
    @breed = breed
    @id = id
  end

  def self.create_table
    sql = <<-SQL
      CREATE TABLE IF NOT EXISTS dogs (
        id INTEGER PRIMARY KEY,
        name TEXT,
        breed TEXT
      )
    SQL
    DB[:conn].execute(sql)
  end

  def self.drop_table
    sql = <<-SQL
      DROP TABLE IF EXISTS dogs
    SQL
    DB[:conn].execute(sql)
  end

  def save
    if self.id
      self
    else
      sql = <<-SQL
        INSERT INTO dogs (name, breed) VALUES (?, ?)
      SQL
      DB[:conn].execute(sql, self.name, self.breed)
      @id = DB[:conn].execute("SELECT last_insert_rowid() FROM dogs")[0][0]
      self
    end
  end

  def self.create name:, breed:
    new_dog = Dog.new(name: name, breed: breed)
    new_dog.save
  end

  def self.find_by_id id
    sql = <<-SQL
      SELECT * FROM dogs WHERE id = ?
    SQL
    DB[:conn].execute(sql, id).map do |row|
      self.new_from_db(row)
    end.first
  end

  def self.new_from_db row
    id, name, breed = row
    self.new(id: id, name: name, breed: breed)
  end

  def self.find_or_create_by name:, breed:
    sql = <<-SQL
      SELECT * FROM dogs WHERE name = ? AND breed = ?
    SQL
    row = DB[:conn].execute(sql, name, breed)[0]

    if !!row
      self.new_from_db(row)
    else
      self.create(name: name, breed: breed)
    end
  end

  def self.find_by_name name
    sql = <<-SQL
      SELECT * FROM dogs WHERE name = ?
    SQL
    DB[:conn].execute(sql, name).map do |row|
      self.new_from_db(row)
    end.first
  end

  def update
    sql = <<-SQL
      UPDATE dogs SET name = ?, breed = ? WHERE id = ?
    SQL
    DB[:conn].execute(sql, name, breed, id)
  end

end
