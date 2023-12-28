#!/bin/bash

# Default values
USE_PROXY=0
PROXY_URL="" # Proxy URL will be set based on the input parameter
MAX_PAGES=5 # Default maximum number of pages

# Function to show help message
show_help() {
    echo "Usage: $0 [options] [search term]"
    echo "Options:"
    echo "  -h          Display this help message."
    echo "  -p, --proxy [proxy URL] Use the specified proxy server for requests."
    echo "  -m, --max-pages Set the maximum number of pages to process (default is 5)."
    echo "  search term The term to search for on arXiv."
    exit 1
}

# Parse command line arguments
while [[ "$#" -gt 0 ]]; do
    case $1 in
        -h) show_help ;;
        -p|--proxy) 
            USE_PROXY=1
            shift
            if [[ -n "$1" ]]; then
                PROXY_URL="$1"
                shift
            else
                echo "Error: '--proxy' requires a proxy URL."
                exit 1
            fi
            ;;
        -m|--max-pages) 
            if [[ -n "$2" && "$2" =~ ^[0-9]+$ ]]; then
                MAX_PAGES="$2"
                shift
            else
                echo "Error: '--max-pages' requires a numeric argument."
                exit 1
            fi
            ;;
        *) SEARCH_TERM="$1" ;;
    esac
    shift
done

if [ -z "$SEARCH_TERM" ]; then
    echo "Error: No search term provided."
    show_help
fi

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

    # Set up proxy if enabled
    #local curl_opts="-A \"$USER_AGENT\""
    local curl_opts=""
    if [ $USE_PROXY -eq 1 ]; then
        if [ -z "$PROXY_URL" ]; then
            echo "Proxy option enabled but no proxy URL provided."
            exit 1
        fi
        curl_opts="$curl_opts -x $PROXY_URL"
    fi

    local search_results=$(curl $curl_opts "$page_url")

    if [ -z "$search_results" ]; then
        echo "Failed to fetch search results from $page_url"
        return
    fi

    local pdf_links=$(echo "$search_results" | grep -o 'href="https://arxiv.org/pdf/[0-9.]\+"')
    echo pdf_links: $pdf_links
    
    if [ -z "$pdf_links" ]; then
        echo "No PDF links found on page $page_url"
        return
    fi

    # Download each PDF
    for link in $pdf_links; do
        local clean_link=$(echo $link | sed 's/href="//' | sed 's/"//' | sed 's/$/.pdf/')
        echo "Downloading $clean_link..."
        
        # Debug: Print the curl command
        echo "curl command: curl $curl_opts -O \"$clean_link\""

        # Execute curl command
        curl $curl_opts -O "$clean_link"

        # Check if the file was downloaded
        if [ $? -ne 0 ]; then
            echo "Failed to download $clean_link"
        fi
    done
}

page_number=0

while [ $page_number -lt $MAX_PAGES ]
do
    page_url="${BASE_SEARCH_URL}&start=${page_number}"
    download_pdfs_from_page "$page_url"
    ((page_number++))
done

echo "Download completed."
