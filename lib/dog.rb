class Dog
attr_reader :id
attr_accessor :name, :breed

def initialize(name:, breed:, id: nil)
  @name = name
  @breed = breed
  @id = id
end

def self.create_table
 sql = <<~SQL
 CREATE TABLE dogs(
   id INTEGER PRIMARY KEY,
   breed TEXT,
   name TEXT
)
SQL
DB[:conn].execute(sql)
end

def self.drop_table
  sql = <<~SQL
  DROP TABLE dogs
  SQL
  DB[:conn].execute(sql)
end

def save
      sql = <<-SQL
        INSERT INTO dogs (breed, name)
        VALUES (?, ?)
      SQL

      DB[:conn].execute(sql, self.breed, self.name)
      @id = DB[:conn].execute("SELECT last_insert_rowid() FROM dogs")[0][0]
      self
end


def self.create(attributes)
  new_dog = Dog.new(attributes)
  new_dog.save
  new_dog
end

def self.new_from_db(row)
  id = row[0]
  name = row[1]
  breed = row[2]
  new_dog = self.new(name:name, breed:breed, id:id)
  new_dog
end

def self.find_by_id(id)
  sql = <<~SQL
  SELECT *
  FROM dogs
  WHERE id = ?
  LIMIT 1
  SQL

  DB[:conn].execute(sql, id).map do |row|
     self.new_from_db(row)
   end.first
end

def self.find_or_create_by(name:, breed:)
  dog = DB[:conn].execute("SELECT * FROM dogs WHERE name = ? AND breed = ?", name, breed)
  if !dog.empty?
    dog_data = dog[0]
    dog = Dog.new(id: dog_data[0], name: dog_data[1], breed: dog_data[2])
  else
    dog = self.create(name: name, breed: breed)
  end
  dog
end


  def self.find_by_name(name)
  sql = <<-SQL
      SELECT *
      FROM dogs
      WHERE name = ?
      LIMIT 1
    SQL

    DB[:conn].execute(sql, name).map do |row|
      self.new_from_db(row)
    end.first
  end

  def update
    sql = <<~SQL
    UPDATE dogs
    SET name = ?, breed = ?
    WHERE id = ?
    SQL
    DB[:conn].execute(sql, self.name, self.breed, self.id)
  end


end
