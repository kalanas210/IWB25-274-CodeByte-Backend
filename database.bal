import ballerinax/postgresql;
import ballerina/log;

configurable string DB_HOST = "localhost";
configurable int DB_PORT = 5432;
configurable string DB_NAME = "socyads_db";
configurable string DB_USER = "postgres";
configurable string DB_PASSWORD = "password";
configurable boolean DB_SSL = false;

public final postgresql:Client dbClient = checkpanic new (
    host = DB_HOST,
    port = DB_PORT,
    user = DB_USER,
    password = DB_PASSWORD,
    database = DB_NAME,
    options = { ssl = DB_SSL }
);

public type User record {
    string id;
    string email;
    string username?;
    string name?;
    string role?;
    boolean verified?;
};

public type Gig record {
    string id;
    string seller_id;
    string title;
    string description?;
    string? category_id;
    string platform;
    string[]? tags;
    string[]? images;
    decimal? rating;
    int? total_reviews;
    int? completed_orders;
    boolean? featured;
    string? status;
    decimal? min_price;
    decimal? max_price;
};

public function createUser(string email, string passwordHash, string username = "", string name = "")
        returns User|error {
    string uname = username.length() > 0 ? username : email.split("@")[0];
    string displayName = name.length() > 0 ? name : uname;
    string sql = "INSERT INTO users (email, username, name, password_hash) VALUES ($1, $2, $3, $4) "
        + "RETURNING id::text as id, email, username, name, role, verified";
    stream<User, error> s = dbClient->query(sql, email, uname, displayName, passwordHash);
    User row = check s.next();
    check s.close();
    return row;
}

public function findUserByEmailAndPassword(string email, string passwordHash) returns User|error? {
    string sql = "SELECT id::text as id, email, username, name, role, verified "
        + "FROM users WHERE email = $1 AND password_hash = $2 LIMIT 1";
    stream<User, error> s = dbClient->query(sql, email, passwordHash);
    User? u = check s.next();
    check s.close();
    return u;
}

public function getUserById(int|String id) returns User|error? {
    string sql = "SELECT id::text as id, email, username, name, role, verified FROM users WHERE id::text = $1";
    string sid = id.toString();
    stream<User, error> s = dbClient->query(sql, sid);
    User? u = check s.next();
    check s.close();
    return u;
}

public function listGigs(string? q = (), string? categorySlug = (), decimal? minPrice = (), decimal? maxPrice = (), string? sortBy = (), string? sortOrder = ()) returns Gig[]|error {
    string sql = "SELECT g.id::text as id, g.seller_id::text as seller_id, g.title, g.description, "
        + "g.category_id::text as category_id, g.platform, g.tags, g.images, g.rating, g.total_reviews, g.completed_orders, g.featured, g.status, "
        + "MIN(gp.price) as min_price, MAX(gp.price) as max_price "
        + "FROM gigs g "
        + "LEFT JOIN categories c ON c.id = g.category_id "
        + "LEFT JOIN gig_packages gp ON gp.gig_id = g.id "
        + "WHERE g.status = 'active' "
        + "AND ($1::text is null OR g.title ILIKE '%' || $1 || '%' OR g.description ILIKE '%' || $1 || '%') "
        + "AND ($2::text is null OR c.slug = $2) "
        + "GROUP BY g.id "
        + "HAVING (($3::numeric is null) OR MIN(gp.price) >= $3) "
        + "AND (($4::numeric is null) OR MIN(gp.price) <= $4) ";

    string orderCol = "g.created_at";
    if sortBy is string {
        if sortBy.equalsIgnoreCase("minPrice") {
            orderCol = "min_price";
        } else if sortBy.equalsIgnoreCase("maxPrice") {
            orderCol = "max_price";
        }
    }
    string dir = "DESC";
    if sortOrder is string {
        if sortOrder.equalsIgnoreCase("asc") { dir = "ASC"; }
        if sortOrder.equalsIgnoreCase("desc") { dir = "DESC"; }
    }
    sql = sql + "ORDER BY " + orderCol + " " + dir + " LIMIT 50";

    stream<Gig, error> s = dbClient->query(sql, q, categorySlug, minPrice, maxPrice);
    Gig[] gigs = check s.toArray();
    check s.close();
    return gigs;
}

public function createGig(int|String sellerId, string title, string description, decimal _price, string categorySlug)
        returns Gig|error {
    // Insert with category resolved from slug; set default platform and empty tags for scaffold
    string sql = "INSERT INTO gigs (seller_id, title, description, category_id, platform, tags, status) "
        + "VALUES ($1::uuid, $2, $3, (SELECT id FROM categories WHERE slug = $4), $5, $6, 'active') "
        + "RETURNING id::text as id, seller_id::text as seller_id, title, description, category_id::text as category_id, platform, tags, images, rating, total_reviews, completed_orders, featured, status";
    string seller = sellerId.toString();
    string[] tags = [];
    stream<Gig, error> s = dbClient->query(sql, seller, title, description, categorySlug, "youtube", tags);
    Gig g = check s.next();
    check s.close();
    return g;
}

public function updateGig(int|String id, int|String sellerId, string title, string description, decimal _price, string categorySlug)
        returns Gig|error {
    string sql = "UPDATE gigs SET title = $3, description = $4, category_id = (SELECT id FROM categories WHERE slug = $5), updated_at = NOW() "
        + "WHERE id::text = $1 AND seller_id::text = $2 RETURNING id::text as id, seller_id::text as seller_id, title, description, category_id::text as category_id, platform, tags, images, rating, total_reviews, completed_orders, featured, status";
    stream<Gig, error> s = dbClient->query(sql, id.toString(), sellerId.toString(), title, description, categorySlug);
    Gig g = check s.next();
    check s.close();
    return g;
}

public function deleteGig(int|String id, int|String sellerId) returns boolean|error {
    string sql = "UPDATE gigs SET status = 'deleted', updated_at = NOW() WHERE id::text = $1 AND seller_id::text = $2";
    sql:ExecutionResult r = check dbClient->execute(sql, id.toString(), sellerId.toString());
    return r.affectedRowCount > 0;
}


