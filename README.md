# PaperDownloader
PaperDownloader is a simple bash script that downloads all papers from arXiv, given a search string. It handles pagination, and a proxy can be specified if necessary.
You can also configure the maximum number of pages to process.

Synopsis:

    Usage: ./PaperDownloader.sh [options] [search term]
    Options:
        -h          Display this help message.
        -p, --proxy [proxy URL] Use the specified proxy server for requests.
        -m, --max-pages Set the maximum number of pages to process (default is 5).
        search term The term to search for on arXiv.

Example call:

    ./PaperDownloader.sh "gaussian splatting nerf"

As of 2023, this call should download about 27 papers to the current directory.

Notes:

- This was more or less a Sunday afternoon 2h hack. Use it at your own risk. No guarantees.
- Currently, all search terms are AND combined. This means that the more search terms you give, the less papers will be found, unless you explicitly give the "OR" keyword.
- Be careful what you give as a search string. The papers will be the same as if you had entered the search string on the arXiv website. So this number can be quite large.
- A good hint might be to test the search string on the arXiv site first.


Todo:

- Support resuming of downloads
- Support target directories to download to
- Avoid duplicate downloads of papers

If you want to contribute to this, feel free to raise a PR.