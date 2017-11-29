class Dog
  attr_accessor :name, :breed
  attr_reader :id

  def initialize(id: nil, name:, breed:)
    @name = name
    @breed = breed
    @id = id
  end

  def self.create_table
    DB[:conn].execute("
      CREATE TABLE IF NOT EXISTS dogs (
        id INTEGER PRIMARY KEY,
        name TEXT,
        breed TEXT);"
      )
  end

  def self.drop_table
    DB[:conn].execute("DROP TABLE IF EXISTS dogs;")
  end

  def save
    DB[:conn].execute("INSERT INTO dogs(name,breed) VALUES (?,?)",self.name, self.breed)
    @id = DB[:conn].execute("SELECT last_insert_rowid() FROM dogs")[0][0]
    self
  end

  def self.create(name:, breed:)
    a=self.new(name: name, breed: breed)
    a.save
    a
  end

  def self.find_by_id(id)
    a=DB[:conn].execute("SELECT * FROM dogs WHERE id = ?", id)[0]
    self.new(id: a[0], name: a[1], breed: a[2])
  end

  def self.new_from_db(row)
    self.new(id: row[0], name: row[1], breed: row[2])
  end

  def self.find_by_name(name)
    a=DB[:conn].execute("SELECT * FROM dogs WHERE name = ?", name)[0]
    self.new_from_db(a)
  end

  def update
    DB[:conn].execute("UPDATE dogs SET name = ?, breed = ?  WHERE id = ?", self.name, self.breed, self.id)
  end

  def self.find_or_create_by(name:, breed:)
    a=DB[:conn].execute("SELECT * FROM dogs WHERE name = ? AND breed = ?", name, breed)

    if a.empty? #create new
      self.create(name: name, breed: breed)
    else #return existing
      self.new_from_db(a[0])
    end
  end

end
