#!/bin/bash

# Function to show help message
show_help() {
    echo "Usage: $0 [search term]"
    echo "  -h          Display this help message."
    echo "  search term The term to search for on arXiv."
    exit 1
}

# Check for help option or if no arguments were provided
if [ "$#" -eq 0 ] || [[ "$1" == "-h" ]]; then
    show_help
fi

# Search term is the first command line argument
SEARCH_TERM="$1"

# URL encoding for the search term
ENCODED_SEARCH_TERM=$(echo $SEARCH_TERM | sed 's/ /%20/g')

# Base URL for arXiv search
BASE_SEARCH_URL="https://arxiv.org/search/?query=$ENCODED_SEARCH_TERM&searchtype=all&source=header"

# Base URL for arXiv PDFs
PDF_BASE_URL="https://arxiv.org"

# User-Agent string
USER_AGENT="Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/58.0.3029.110 Safari/537.36"

# Function to download PDFs from a given page
download_pdfs_from_page() {
    local page_url=$1
    echo "Fetching results from: $page_url"

    # Use curl to fetch search results with a User-Agent string
    local search_results=$(curl -x "http://127.0.0.1:3128" -A "$USER_AGENT" -s "$page_url")
    #echo search_results: ${search_results}

    # Check if search_results is empty
    if [ -z "$search_results" ]; then
        echo "Failed to fetch search results from $page_url"
        return
    fi

    # Parse the search results to find PDF links
    local pdf_links=$(echo "$search_results" | grep -o 'href="https://arxiv.org/pdf/[0-9.]\+"')
    #echo pdf_links: ${pdf_links}

    if [ -z "$pdf_links" ]; then
        echo "No PDF links found on page $page_url"
        return
    fi

    # Download each PDF
    for link in $pdf_links; do
        # Clean the link and append .pdf
        local clean_link=$(echo $link | sed 's/href="//' | sed 's/"//' | sed 's/$/.pdf/')
        echo "Downloading $clean_link..."
        curl -x "http://127.0.0.1:3128" -O "$clean_link"
    done
}

# Initial page number
page_number=0

# Maximum number of pages to process
max_pages=500 # Adjust as needed

while [ $page_number -lt $max_pages ]
do
    # Construct search URL for the current page
    page_url="${BASE_SEARCH_URL}&start=${page_number}"
    
    # Download PDFs from the current page
    download_pdfs_from_page "$page_url"

    # Increment page number
    ((page_number++))
done

echo "Download completed."
