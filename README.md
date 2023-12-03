# Project: BoxOfficeInsight
Analysis of factors that influence box office performance

The project employs a multidimensional method to analyze factors influencing box office performance, such as production budget, director reputation, movie genre, and movie reputation. To collect comprehensive and relevant data, various primary sources are utilized, focusing on these variables. This includes collecting movie data, sales information, and movie reviews, which provide a broad spectrum of insights into the factors affecting box office success. The datasets were collected from Metacritic and IMDb.

# Database Design
Entity-Relationship-Diagram (ERD): The project includes a meticulously designed ERD, which serves as a visual guide to the database's structure. This ERD highlights the relationships, entities, and attributes within the dataset, offering clarity on how different tables are interconnected. It's a critical tool for understanding the data's organization and facilitating effective data retrieval.

# Database Schema as Illustrated in the SQL File (boxOffice.sql):
**movie Table:** Holds comprehensive data on individual movies, including various attributes like title, studio, rating, runtime, director, and more. It forms the core of the movie-related data.
**sales Table:** Focuses on the financial aspects of the movies, capturing details like box office performance, production budget, and opening weekend revenues.

# Data Cleaning and Analysis in Jupyter Notebook (boxOffice.ipynb):
**Python Libraries:** The notebook uses libraries such as pandas for data manipulation and matplotlib for visualization, indicating sophisticated data handling and analysis.
**Database Connection and Interaction:** Utilized psycopg2 to connect to the PostgreSQL database, enabling the retrieval and manipulation of data stored in the defined tables.
**Data Analysis and Visualization:** The notebook contains comprehensive analysis and visualization of the data, correlating the collected data with box office performance.
**Integration of Data Sources:** The project integrates data from various sources, aligning movie attributes, financials, and reviews into a cohesive dataset. This integration is crucial for a holistic analysis of what influences a movie's success at the box office.

# Additional Tables in ERD:
'Movie_genre', 'Movie_awards', 'Expert Review', and 'User Review' Tables: These tables, as indicated in the ERD, which play a significant role in the project. They store data on genres, awards, professional critiques, and audience reactions, all of which are pivotal in understanding the multi-faceted nature of box office performance.

The project employs a rigorous approach to data collection, organization, and analysis. The SQL file and the Jupyter notebook are instrumental in creating a structured, analyzable dataset that can yield insights into the dynamics of box office performance. The ERD further helps in visualizing and understanding the complex relationships within the data, ensuring a thorough and methodical analysis.
